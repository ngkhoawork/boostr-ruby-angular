require 'rubygems'
require 'zip'

class Deal < ActiveRecord::Base
  SAFE_COLUMNS = %i{start_date end_date name budget created_at updated_at
                    closed_at budget_loc web_lead type source initiative}
  SAFE_REFLECTIONS = %i{currency teams}

  include GoogleSheetsExportable
  include WorkflowCallbacks
  include PgSearch

  multisearchable against: [:name, :advertiser_name, :agency_name], 
                  additional_attributes: lambda { |deal| { company_id: deal.company_id, order: 2 } },
                  if: lambda { |deal| !deal.deleted? }

  acts_as_paranoid

  belongs_to :company
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id', counter_cache: :advertiser_deals_count
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id', counter_cache: :agency_deals_count
  belongs_to :stage, counter_cache: true
  belongs_to :stageinfo, -> { select(:id, :name, :probability, :open, :updated_at) }, class_name: 'Stage', foreign_key: 'stage_id'
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :stage_updator, class_name: 'User', foreign_key: 'stage_updated_by'
  belongs_to :previous_stage, class_name: 'Stage', foreign_key: 'previous_stage_id'
  belongs_to :initiative
  belongs_to :lead
  belongs_to :type, class_name: 'Option'
  belongs_to :source, class_name: 'Option'
  belongs_to :close_reason, class_name: 'Option'

  # Restrict with exception is used to rollback any
  # other potential dependent: :destroy relations
  has_one :io, class_name: "Io", foreign_key: 'deal_id', dependent: :restrict_with_exception
  has_one :pmp, class_name: "Pmp", foreign_key: 'deal_id', dependent: :restrict_with_exception

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'
  has_one :egnyte_folder, as: :subject
  has_many :contracts, dependent: :nullify
  has_many :contacts, -> { uniq }, through: :deal_contacts
  has_many :deal_contacts, dependent: :destroy
  has_many :deal_products, dependent: :destroy
  has_many :deal_product_budgets, through: :deal_products
  has_many :deal_logs
  has_many :products, -> { distinct }, through: :deal_products
  has_many :deal_members
  has_many :deal_members_share_ordered, -> { order(share: :desc) }, class_name: 'DealMember', foreign_key: 'deal_id'
  has_many :users, through: :deal_members
  has_many :values, as: :subject
  has_many :options, through: :values
  has_many :deal_stage_logs
  has_many :activities
  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :assets, as: :attachable
  has_many :integrations, as: :integratable
  has_many :requests
  has_many :audit_logs, as: :auditable
  has_many :teams, through: :users, source: 'team'

  has_one :billing_deal_contact, -> { where(role: 'Billing') }, class_name: 'DealContact'
  has_one :billing_contact, through: :billing_deal_contact, source: :contact
  has_many :spend_agreement_deals, dependent: :destroy
  has_many :spend_agreements, through: :spend_agreement_deals

  has_one :deal_custom_field, dependent: :destroy, inverse_of: :deal
  has_one :latest_happened_activity, -> { self.select_values = ["DISTINCT ON(activities.deal_id) activities.*"]
    order('activities.deal_id', 'activities.happened_at DESC')
  }, class_name: 'Activity'
  has_one :type_field, -> { where(subject_type: 'Deal', name: 'Deal Type') }, through: :company, source: :fields
  has_one :deal_source_field, -> { where(subject_type: 'Deal', name: 'Deal Source') }, through: :company, source: :fields
  has_one :close_reason_field, -> { where(subject_type: 'Deal', name: 'Close Reason') }, through: :company, source: :fields

  validates :advertiser_id, :start_date, :end_date, :name, :stage_id, presence: true
  validate :active_exchange_rate
  validate :billing_contact_presence
  validate :single_billing_contact
  validate :account_manager_presence
  validate :disable_manual_deal_won_validation, on: :manual_update
  validate :restrict_deal_reopen_validation
  validate :base_fields_presence

  accepts_nested_attributes_for :deal_custom_field
  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  delegate :name, to: :advertiser, allow_nil: true, prefix: true
  delegate :name, to: :stage, allow_nil: true, prefix: true
  delegate :probability, to: :stage, allow_nil: true, prefix: true
  delegate :open?, to: :stage, allow_nil: true, prefix: true
  delegate :active?, to: :stage, allow_nil: true, prefix: true

  attr_accessor :modifying_user, :manual_update, :custom_trigger, :info_messages, :spend_agreements_before_track, :spend_agreements_after_track

  before_update do
    if curr_cd_changed?
      update_products_currency
    end

    if stage_id_changed?
      update_stage
      recalculate_currency
      update_close
    end
  end

  after_update do
    if stage_id_changed?
      generate_io_or_pmp
      send_ealert
      log_stage_changes
    end
    Deal::ResetBudgetsService.new(self).perform if (start_date_changed? || end_date_changed?)
    send_lost_deal_notification
    connect_deal_clients
    log_start_date_changes if start_date_changed?
  end

  after_commit :integrate_with_operative
  after_update :track_spend_agreements, if: -> { run_agreements_tracking? && manual_update }
  after_update :build_agreements_info_message

  before_create do
    update_stage
    set_freezed
    if self.closed_at.nil?
      self.closed_at = created_at unless stage.open?
    end
  end

  after_create do
    generate_deal_members
    send_new_deal_notification
    send_ealert
    connect_deal_clients
    log_stage_changes
    track_spend_agreements if manual_update
  end

  after_save do 
    update_associated_search_documents if name_changed?
  end

  after_commit :asana_connect, on: [:create]

  before_destroy do
    update_stage
  end

  after_destroy do
    update_pipeline_fact(self)
    update_associated_search_documents
  end

  after_commit :setup_egnyte_folders, on: [:create]
  after_commit :update_egnyte_folder, on: [:update]
  after_commit :create_hoopla_newsflash_event, on: [:create, :update]

  set_callback :save, :after, :update_pipeline_fact_callback

  scope :for_client, -> (client_id) { where('advertiser_id in (:client_id) OR agency_id in (:client_id)', client_id: client_id) if client_id.present? }
  scope :for_time_period, -> (start_date, end_date) do
    where('start_date <= ? AND end_date >= ?', end_date, start_date) if start_date.present? && end_date.present?
  end
  scope :closed_in, -> (duration_in_days) { where('closed_at >= ?', Time.now.utc.beginning_of_day - duration_in_days.days) }
  scope :closed_at, -> (start_date, end_date) do
    where('closed_at >= ? and closed_at <= ?', start_date, end_date) if start_date.present? && end_date.present?
  end
  scope :started_at, -> (start_date, end_date) { where('deals.created_at >= ? and deals.created_at <= ?', start_date, end_date) }
  scope :open, -> { joins(:stage).where('stages.open IS true') }
  scope :close_status, -> { joins(:stage).where('stages.open IS false OR stages.probability = 100') }
  scope :open_partial, -> { where('deals.open IS true') }
  scope :closed, -> { joins(:stage).where('stages.open IS false') }
  scope :active, -> { where('deals.deleted_at is NULL') }
  scope :at_percent, -> (percentage) { joins(:stage).where('stages.probability = ?', percentage) }
  scope :greater_than, -> (percentage) { joins(:stage).where('stages.probability >= ?', percentage) }
  scope :less_than, -> (percentage) { joins(:stage).where('stages.probability < ?', percentage) }
  scope :more_than_percent, -> (percentage)  { joins(:stage).where('stages.probability >= ?', percentage) }
  scope :by_values, -> (value_ids) { joins(:values).where('values.option_id in (?)', value_ids) unless value_ids.empty? }
  scope :by_deal_team, -> (user_ids) { joins(:deal_members).where('deal_members.user_id in (?)', user_ids) if user_ids }
  scope :won, -> { closed.includes(:stage).where(stages: { probability: 100 }) }
  scope :lost, -> { closed.includes(:stage).where(stages: { probability: 0 }) }
  scope :by_stage_id, -> (stage_id) { where(stage_id: stage_id) if stage_id.present? }
  scope :grouped_open_by_probability_sum, -> { open.includes(:stage).group('stages.probability').sum('budget') }
  scope :by_name, -> (name) { where('deals.name ilike ?', "%#{name}%") }
  scope :by_product_id, -> (product_id) { joins(:products).where(products: { id: product_id } ) if product_id.present? }
  scope :by_team_id, -> (team_id) do
    joins(:deal_members)
      .where(deal_members: {
        user_id: Team.find_by_id(team_id)&.all_members_and_leaders_ids
      }) if team_id.present?
  end
  scope :by_seller_id, -> (seller_id) do
    joins(:deal_members).where(deal_members: { user_id: seller_id }) if seller_id.present?
  end
  scope :by_budget_range, -> (from, to) { where(budget: from..to) if from.present? && to.present? }
  scope :by_curr_cd, -> (curr_cd) { where(curr_cd: curr_cd) if curr_cd.present? }
  scope :by_start_date, -> (start_date, end_date) do
    where(start_date: start_date..end_date) if start_date.present? && end_date.present?
  end
  scope :by_closed_at, -> (closed_at) do
    where(closed_at: closed_at.beginning_of_year.to_datetime.beginning_of_day..closed_at.end_of_year.to_datetime.end_of_day) if closed_at.present?
  end
  scope :by_advertisers, -> (ids) { where('advertiser_id in (?)', ids) if ids.present? }
  scope :by_agencies, -> (ids) { where('agency_id in (?)', ids) if ids.present? }
  scope :by_created_date, -> (start_date, end_date) do
    where(created_at: (start_date.to_datetime.beginning_of_day)..(end_date.to_datetime.end_of_day)) if start_date.present? && end_date.present?
  end
  scope :by_stage_ids, -> (stage_ids) { where(stage_id: stage_ids) if stage_ids.present? }
  scope :by_options, -> (option_id) { joins(:options).where(options: { id: option_id }) if option_id.any? }
  scope :by_ids, -> (ids) { where('deals.id in (?)', ids) if ids.present? }
  scope :with_all_options, -> (option_ids) do
    if option_ids.present? && !option_ids.empty?
      ids = Value.where(subject_type: 'Deal')
               .by_option_ids(option_ids)
               .group(:subject_id)
               .having('count(distinct option_id) >= ?', option_ids.length)
               .pluck(:subject_id)
      where('deals.id in (?)', ids)
    end
  end
  scope :has_io, -> {
    joins(:io).where('ios.id IS NOT NULL')
  }
  scope :by_sales_process, -> (sales_process_id) do
    joins(:stage).where('stages.sales_process_id = ?', sales_process_id) if sales_process_id.present?
  end
  scope :by_name_or_advertiser_name_or_agency_name, -> (name) do
    joins('LEFT JOIN clients advertisers ON advertisers.id = deals.advertiser_id AND advertisers.deleted_at IS NULL')
        .joins('LEFT JOIN clients agencies ON agencies.id = deals.agency_id AND agencies.deleted_at IS NULL')
        .where('deals.name ilike :name OR advertisers.name ilike :name OR agencies.name ilike :name', name: "%#{name}%") if name
  end
  scope :by_external_id, -> (external_id) do
    joins(:integrations)
        .where(
          'integrations.external_type = ? AND integrations.external_id = ?',
          'operative',
          external_id
        ) if external_id.present?
  end
  scope :close_reason_selection, -> (deal_id) do
    close_reason_field.values.find_by(subject_id: deal_id)
  end

  attr_accessor :manual_update

  def set_freezed
    self.freezed = company.default_deal_freeze_budgets
  end

  def run_agreements_tracking?
    advertiser_id_changed? || agency_id_changed? || start_date_changed? || end_date_changed?
  end

  def update_pipeline_fact_callback
    if stage_id_changed?
      update_pipeline_fact_stage(stage_id_was, stage_id)
    end

    if start_date_changed? || end_date_changed?
      if start_date_was && end_date_was
        s_date = [start_date_was, start_date].min
        e_date = [end_date_was, end_date].max
      else
        s_date = start_date
        e_date = end_date
      end
      update_pipeline_fact_date(s_date, e_date)
    end

    if open_changed?
      update_pipeline_fact(self)
    end
    WorkflowWorker.perform_async(deal_id: id, type: 'update') if budget_changed? && manual_update
  end

  def asana_connect
    AsanaConnectWorker.perform_in(10.minutes, self.id) if asana_integration_required?
  end

  def info_messages
    @info_messages ||= []
  end

  def build_agreements_info_message
    message = SpendAgreements::InfoMessageBuilder.new(before_track: self.spend_agreements_before_track,
                                                      after_track: self.spend_agreements_after_track,
                                                      message_context: :deal).perform
    self.info_messages << message if message
  end

  def track_spend_agreements
    self.spend_agreements_before_track = self.spend_agreements.pluck_to_hash(:id, :name)
    SpendAgreementTrackingService.new(deal: self).track_spend_agreements
    self.spend_agreements_after_track = self.spend_agreements.pluck_to_hash(:id, :name)
  end

  def asana_integration_required?
    config = self.company.asana_connect_configurations.first
    config.present? && config.switched_on?
  end

  def integrate_with_operative
    if previous_changes[:stage_id].present? && operative_integration_allowed?
      OperativeIntegrationWorker.perform_async(self.id)
    end
  end

  def operative_api_config
    @_operative_api_config ||= self.company.operative_api_config
  end

  def operative_integration_allowed?
    company_allowed_use_operative? && operative_switched_on? && deal_eligible_for_integration
  end

  def company_allowed_use_operative?
    %w(22 29 44).include? self.company_id.to_s
  end

  def operative_switched_on?
    operative_api_config.present? && operative_api_config.switched_on?
  end

  def deal_eligible_for_integration
    stage_greater_eql_threshold && integration_happened_or_recurring || deal_lost?
  end

  def integration_happened_or_recurring
    operative_api_config.recurring? || !integrations.operative.present?
  end

  def stage_greater_eql_threshold
    stage.probability >= operative_api_config.trigger_on_deal_percentage
  end

  def deal_lost?
    closed_lost? && integrations.operative.present?
  end

  def closed_lost?
    stage.probability.eql?(0) && !stage.open?
  end

  def closed_won?
    stage.probability.eql?(100) && stage.open? == false
  end

  def just_switched_to_closed_won?
    closed_won? && previous_changes[:stage_id]
  end

  def closed_with_io?
    !stage.open? && stage.probability == 100 && io.present?
  end

  def active_exchange_rate
    if curr_cd != 'USD'
      unless company.active_currencies.include?(curr_cd)
        errors.add(:curr_cd, "#{self.curr_cd} does not have an active exchange rate")
      end
    end
  end

  def single_billing_contact
    errors.add(:deal, "Only one billing contact allowed") unless no_more_one_billing_contact?
  end

  def billing_contact_presence
    return unless stage.present?
    validation = company.validations.find_by(
      object: 'Billing Contact',
      factor: stage.sales_process_id
    )
    stage_threshold = validation&.criterion&.value&.probability

    if stage_threshold && stage.probability >= stage_threshold && !self.has_billing_contact?
      errors.add(:stage, "#{self.stage&.name} requires a valid Billing Contact with address")
    end
  end

  def account_manager_presence
    return unless stage.present?
    validation = company.validations.find_by(
      object: 'Account Manager',
      factor: stage.sales_process_id
    )
    stage_threshold = validation&.criterion&.value&.probability

    if stage_threshold && stage.probability >= stage_threshold && !self.has_account_manager_member?
      errors.add(:stage, "#{self.stage&.name} requires an Account Manager on Deal")
    end
  end

  def base_field_validations
    self.company.validations_for("#{self.class} Base Field")
  end

  def base_fields_presence
    if self.company_id.present?
      factors = base_field_validations.joins(:criterion).where('values.value_boolean = ?', true).pluck(:factor)
      factors.each do |factor|
        errors.add(factor, 'must be present') if public_send(factor).blank?
      end
    end
  end

  def disable_manual_deal_won_validation
    validation = company.validation_for(:disable_deal_won)
    disable_flag = validation.criterion.try(:value) if validation

    if validation && disable_flag == true && stage && stage.probability == 100 && stage.open? == false
      errors.add(
        :stage, "Deals can't be updated to #{self.stage.try(:name)} manually. Deals can only be set to #{self.stage.try(:name)} from API integration"
      )
    end
  end

  def restrict_deal_reopen_validation
    return unless modifying_user

    if stage_reopened? && restricted_reopen_for_non_admins? && !modifying_user.is_admin
      errors.add(:stage, 'Only admins are allowed to re-open deals')
    end
  end

  def stage_was
    stage_id_was && Stage.find(stage_id_was)
  end

  def stage_reopened?
    stage_was&.closed? && stage&.open?
  end

  def restricted_reopen_for_non_admins?
    company.validation_for(:restrict_deal_reopen)&.criterion&.value
  end

  def no_more_one_billing_contact?
    self.deal_contacts.where(role: 'Billing').count <= 1
  end

  def has_billing_contact?
    !!(billing_contact) && billing_contact.valid?
  end

  def has_account_manager_member?
    self.users.exists?(user_type: ACCOUNT_MANAGER)
  end

  def account_manager
    self.users.where(user_type: 3)
  end

  def seller
    self.users.where(user_type: 1)
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    formatted_name = name
    formatted_name += ", #{advertiser.try(:name)}" if advertiser
    formatted_name += ", #{stage.try(:name)}" if stage
  end

  def as_json(options = {})
    if options[:override].present? && options[:override] == true
      super(options[:options])
    else
      super(
        options.merge(
          include: [
            :creator,
            :advertiser,
            :agency,
            :stage,
            :values,
            :deal_custom_field,
            deal_members: {
              methods: [:name]
            },
            activities: {
              include: {
                creator: {},
                publisher: { only: [:id, :name] },
                contacts: {},
                assets: {
                  methods: [
                    :presigned_url
                  ]
                }
              }
            }
          ],
          methods: [
            :formatted_name
          ]
        )
      )
    end
  end

  def in_period_open_amt(start_date, end_date)
    total = 0
    deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
      if deal_product_budget.deal_product.open == true
        from = [start_date, deal_product_budget.start_date].max
        to = [end_date, deal_product_budget.end_date].min
        num_days = (to.to_date - from.to_date) + 1
        total += deal_product_budget.daily_budget.to_f * num_days
      end
    end
    total
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def days_per_month
    array = []

    case months.length
    when 0
      array
    when 1
      array << days
    when 2
      array << ((start_date.end_of_month + 1) - start_date).to_i
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    else
      array << ((start_date.end_of_month + 1) - start_date).to_i
      (months[1..-2] || []).each do |month|
        array << Time.days_in_month(month[1], month[0])
      end
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    end
    array
  end

  def exchange_rate
    company.exchange_rate_for(currency: self.curr_cd)
  end

  def update_products_currency
    deal_product_budgets.update_all("budget_loc = budget * #{self.exchange_rate}")
    deal_products.map{ |deal_product| deal_product.update_budget }
    self.budget_loc = budget * self.exchange_rate
  end

  def generate_deal_members
    # This only gets called on create where the Deal has inherently been touched
    ActiveRecord::Base.no_touching do
      if advertiser.client_members.empty? && creator
        deal_members.create(user_id: creator.id, share: 100)
      else
        should_create = true
        total_share = 0
        advertiser.client_members.each do |client_member|
          deal_member = deal_members.create(client_member.defaults)

          if client_member.role_value_defaults
            deal_member.values.create(client_member.role_value_defaults)
          end

          total_share += client_member.share
          if creator && client_member.user_id == creator.id
            should_create = false
          end
        end

        if creator && should_create == true
          deal_members.create(user_id: creator.id, share: [100 - total_share, 0].max)
        end
      end
    end
  end

  def self.get_option(subject, field_name)
    if !subject.nil?
      subject_fields = subject.fields
      if !subject_fields.nil?
        field = subject_fields.find_by_name(field_name)
        value = subject.values.find_by_field_id(field.id) if !field.nil?
        option = value.option.name if !value.nil? && !value.option.nil?
      end
    end
    return option
  end

  def self.workflowable_reflections
    %i{
        advertiser agency stage creator updator
        io contacts deal_product_budgets products
        users teams deal_custom_field deal_products deal_members
    }
  end

  def deal_source_value
    field_id = self.fields.find_by_name('Deal Source').id

    !!self.values.find{|val| val.field_id == field_id}
  end

  def deal_type_value
    field_id = self.fields.find_by_name('Deal Type').id

    !!self.values.find{|val| val.field_id == field_id}
  end

  def get_option_value_from_raw_fields(field_data, field_name)
    if field = field_data.find { |field| field.include? field_name }
      self.values.find { |value| value.field_id == field[0] }.try(:option).try(:name)
    end
  end

  def latest_activity_csv_string
    if latest_happened_activity.present?
      data = ''
      data += "Date: #{latest_happened_activity.happened_at.strftime("%m-%d-%Y %H:%M:%S")}\n"
      data += "Type: #{latest_happened_activity.activity_type_name}\n"
    else
      ''
    end
  end

  def self.to_pipeline_report_csv(deals, company, product_filter)
    deal_settings_fields = company.fields.where(subject_type: 'Deal').pluck(:id, :name)

    CSV.generate do |csv|
      deal_ids = deals.collect{|deal| deal.id}

      range = DealProductBudget
      .joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
      .select("distinct(start_date)")
      .where("deal_products.deal_id in (?)", deal_ids)
      .order("start_date asc")
      .collect{|deal_product_budget| deal_product_budget.start_date.try(:beginning_of_month)}
      .compact
      .uniq

      header = []
      header << "Team Member"
      header << "Advertiser"
      header << "Name"
      header << "Agency"
      header << 'Agency Parent'
      header << "Stage"
      header << "%"
      header << "Budget"
      header << "Latest Activity"
      header << "Deal Type"
      header << "Deal Source"
      header << "Team"
      header << "Next Steps"
      header << "Next Steps Due"
      header << "Start Date"
      header << "End Date"
      range.each do |product_time|
        header << product_time.strftime("%Y-%m")
      end
      deal_custom_field_names = company.deal_custom_field_names.where("disabled IS NOT TRUE").order("position asc")
      deal_custom_field_names.each do |deal_custom_field_name|
        header << deal_custom_field_name.field_label
      end

      csv << header
      deals.each do |deal|
        line = [
            deal.deal_members_share_ordered.collect {|deal_member| deal_member.username.first_name + " " + deal_member.username.last_name + " (" + deal_member.share.to_s + "%)"}.join(","),
            deal.advertiser ? deal.advertiser.name : nil,
            deal.name,
            deal.agency ? deal.agency.name : nil,
            deal.agency.try(:parent_client).try(:name),
            deal.stageinfo.name,
            deal.stageinfo.probability.nil? ? "" : deal.stageinfo.probability.to_s + "%",
            "$" + (deal.budget.nil? ? 0 : deal.budget).round.to_s
        ]
        line << deal.latest_activity_csv_string
        line << deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Type')
        line << deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Source')
        line << deal.team_for_user_with_highest_share
        line << deal.next_steps
        line << deal.next_steps_due
        line << deal.start_date
        line << deal.end_date

        selected_products = deal
          .deal_products
          .reject{ |deal_product| !product_filter.include?(deal_product.product_id) if product_filter }
          .map(&:id)

        deal_product_budgets = deal.deal_product_budgets
          .select{ |budget| selected_products.include?(budget.deal_product_id) }
          .group_by{|budget| budget.start_date.beginning_of_month}
          .collect{|key, value| {start_date: key, budget: value.map(&:budget).compact.reduce(:+)} }

        range.each do |product_time|
          if dpb = deal_product_budgets.find { |dpb| dpb[:start_date].try(:beginning_of_month) == product_time }
            line << "$#{dpb[:budget].to_f.round.to_s}"
          else
            line << "$0"
          end
        end

        deal_custom_field = deal.deal_custom_field.as_json
        deal_custom_field_names.each do |deal_custom_field_name|
          field_name = deal_custom_field_name.field_type + deal_custom_field_name.field_index.to_s
          value = nil
          if deal_custom_field.present?
            value = deal_custom_field[field_name]
          end
          # line << value

          case deal_custom_field_name.field_type
            when "currency"
              line << '$' + (value || 0).to_s
            when "percentage"
              line << (value || 0).to_s + "%"
            when "number", "integer"
              line << (value || 0)
            when "datetime"
              line << (value.present? ? (value.strftime("%Y-%m-%d")) : 'N/A')
            else
              line << (value || 'N/A')
          end
        end

        csv << line
      end
    end
  end

  def self.to_pipeline_summary_report_csv(company)
    CSV.generate do |csv|
      deals = company.deals.active.greater_than(50)
      data = {
        'Summary' => {
          '50% Prospects' => nil,
          '75% Prospects' => nil,
          '90% Prospects' => nil,
          'Booked' => nil,
          'Total' => nil
        },
        'Booked' => nil,
        '50% Prospects' => nil,
        '75% Prospects' => nil,
        '90% Prospects' => nil
      }

      current_year = Time.now.utc.year
      deals.each do |deal|
        if deal.stage.probability == 100
          percent_key = "Booked"
        else
          percent_key = deal.stage.probability.to_s + "% Prospects"
        end
        if (!data['Summary']['Total'])
          data['Summary']['Total'] = {}
          for i in 1..12
            data['Summary']['Total'][i.to_s] = 0
          end
          for i in 1..4
            data['Summary']['Total']['Q' + i.to_s] = 0
            data['Summary']['Total']['FY'] = 0
          end

        end
        if (!data['Summary'][percent_key])
          data['Summary'][percent_key] = {}
          for i in 1..12
            data['Summary'][percent_key][i.to_s] = 0
          end
          for i in 1..4
            data['Summary'][percent_key]['Q' + i.to_s] = 0
            data['Summary'][percent_key]['FY'] = 0
          end
        end
        if (!data[percent_key])
          data[percent_key] = {}
        end

        deal.deal_products.each do |deal_product|
          month = deal_product.start_date.month
          if deal_product.start_date.year != current_year
            next
          end
          data['Summary'][percent_key]['FY'] += deal_product.budget
          data['Summary'][percent_key][month.to_s] += deal_product.budget
          data['Summary'][percent_key]['Q' + ((month / 3.0).ceil.to_s)] += deal_product.budget
          data['Summary']['Total']['FY'] += deal_product.budget
          data['Summary']['Total'][month.to_s] += deal_product.budget
          data['Summary']['Total']['Q' + ((month / 3.0).ceil.to_s)] += deal_product.budget

          deal.deal_members.each do |deal_member|
            user = deal_member.user
            user_key = user.first_name + ' ' + user.last_name

            if (!data[percent_key][user_key])
              data[percent_key][user_key] = {}
              for i in 1 .. 12
                data[percent_key][user_key][i.to_s] = 0
              end
              for i in 1 .. 4
                data[percent_key][user_key]['Q' + i.to_s] = 0
                data[percent_key][user_key]['FY'] = 0
              end
            end

            if (!data[percent_key]['Total'])
              data[percent_key]['Total'] = {}
              for i in 1 .. 12
                data[percent_key]['Total'][i.to_s] = 0
              end
              for i in 1 .. 4
                data[percent_key]['Total']['Q' + i.to_s] = 0
                data[percent_key]['Total']['FY'] = 0
              end
            end
            user_product_budget = deal_product_budget.budget * deal_member.share / 100
            data[percent_key][user_key]['FY'] += user_product_budget
            data[percent_key][user_key][month.to_s] += user_product_budget
            data[percent_key][user_key]['Q' + ((month / 3.0).ceil.to_s)] += user_product_budget
            data[percent_key]['Total']['FY'] += user_product_budget
            data[percent_key]['Total'][month.to_s] += user_product_budget
            data[percent_key]['Total']['Q' + ((month / 3.0).ceil.to_s)] += user_product_budget
          end
        end
      end

      data.each do |title, data_obj|
        header = [
            title,
            "Jan",
            "Feb",
            "Mar",
            "Q1 Total",
            "Apr",
            "May",
            "Jun",
            "Q2 Total",
            "Jul",
            "Aug",
            "Sep",
            "Q3 Total",
            "Oct",
            "Nov",
            "Dec",
            "Q4 Total",
            "FY Total",
        ]
        csv << header


        if data_obj.nil?
          next
        end

        data_obj.each do |key,row|
          if key == "Total" || row.nil?
            next
          end
          line = [
            key,
            "$" + row['1'].round.to_s,
            "$" + row['2'].round.to_s,
            "$" + row['3'].round.to_s,
            "$" + row['Q1'].round.to_s,
            "$" + row['4'].round.to_s,
            "$" + row['5'].round.to_s,
            "$" + row['6'].round.to_s,
            "$" + row['Q2'].round.to_s,
            "$" + row['7'].round.to_s,
            "$" + row['8'].round.to_s,
            "$" + row['9'].round.to_s,
            "$" + row['Q3'].round.to_s,
            "$" + row['10'].round.to_s,
            "$" + row['11'].round.to_s,
            "$" + row['12'].round.to_s,
            "$" + row['Q4'].round.to_s,
            "$" + row['FY'].round.to_s
          ]
          csv << line
        end
        line = [
            "Total",
            "$" + data_obj['Total']['1'].round.to_s,
            "$" + data_obj['Total']['2'].round.to_s,
            "$" + data_obj['Total']['3'].round.to_s,
            "$" + data_obj['Total']['Q1'].round.to_s,
            "$" + data_obj['Total']['4'].round.to_s,
            "$" + data_obj['Total']['5'].round.to_s,
            "$" + data_obj['Total']['6'].round.to_s,
            "$" + data_obj['Total']['Q2'].round.to_s,
            "$" + data_obj['Total']['7'].round.to_s,
            "$" + data_obj['Total']['8'].round.to_s,
            "$" + data_obj['Total']['9'].round.to_s,
            "$" + data_obj['Total']['Q3'].round.to_s,
            "$" + data_obj['Total']['10'].round.to_s,
            "$" + data_obj['Total']['11'].round.to_s,
            "$" + data_obj['Total']['12'].round.to_s,
            "$" + data_obj['Total']['Q4'].round.to_s,
            "$" + data_obj['Total']['FY'].round.to_s
        ]
        csv << line
        csv << []
      end
    end
  end

  def self.to_csv(deals, company)
    CSV.generate do |csv|
      header = ['Deal ID', 'Name', 'Advertiser',
                'Agency', 'Team Member', 'Budget',
                'Currency', 'Stage', 'Probability',
                'Type', 'Source', 'Next Steps',
                'Start Date', 'End Date', 'Created Date',
                'Closed Date', 'Close Reason', 'Budget USD', 'Created By']

      deal_custom_field_names = company.deal_custom_field_names.where("disabled IS NOT TRUE").order("position asc")
      deal_custom_field_names.each do |deal_custom_field_name|
        header << deal_custom_field_name.field_label
      end

      deal_settings_fields = company.fields.where(subject_type: 'Deal').pluck(:id, :name)

      csv << header
      deals
      .includes(:agency, :advertiser, :stage, :users, :deal_custom_field, values: :option)
      .find_each do |deal|
        agency_name = deal.agency.try(:name)
        advertiser_name = deal.advertiser.try(:name)
        stage_name = deal.stage.try(:name)
        stage_probability = deal.stage.try(:probability)
        budget_loc = (deal.budget_loc.try(:round) || 0)
        budget_usd = (deal.budget.try(:round) || 0)

        member = deal.deal_members.collect {|deal_member| deal_member.email + "/" + deal_member.share.to_s}.join(";")
        line = [
          deal.id,
          deal.name,
          advertiser_name,
          agency_name,
          member,
          budget_loc,
          deal.curr_cd,
          stage_name,
          stage_probability,
          deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Type'),
          deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Source'),
          deal.next_steps,
          deal.start_date,
          deal.end_date,
          deal.created_at.strftime("%Y-%m-%d"),
          deal.closed_at,
          deal.get_option_value_from_raw_fields(deal_settings_fields, 'Close Reason'),
          budget_usd,
          deal.creator.email
        ]
        deal_custom_field = deal.deal_custom_field.as_json
        deal_custom_field_names.each do |deal_custom_field_name|
          field_name = deal_custom_field_name.field_type + deal_custom_field_name.field_index.to_s
          value = nil
          if deal_custom_field.present?
            value = deal_custom_field[field_name]
          end
          # line << value

          case deal_custom_field_name.field_type
            when "currency"
              line << '$' + (value || 0).to_s
            when "percentage"
              line << (value || 0).to_s + "%"
            when "number", "integer"
              line << (value || 0)
            when "datetime"
              line << (value.present? ? (value.strftime("%Y-%m-%d %H:%M:%S")) : 'N/A')
            else
              line << (value || 'N/A')
          end
        end
        csv << line
      end
    end
  end

  def self.to_zip
    deals_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Advertiser", "Agency", "Team Member", "Budget", "Currency", "Stage", "Probability", "Type", "Source", "Next Steps", "Start Date", "End Date", "Created Date", "Closed Date", "Close Reason", "Budget USD"]
      all.each do |deal|
        agency_name = deal.agency.present? ? deal.agency.name : nil
        advertiser_name = deal.advertiser.present? ? deal.advertiser.name : nil
        stage_name = deal.stage.present? ? deal.stage.name : nil
        stage_probability = deal.stage.present? ? deal.stage.probability : nil
        budget_loc = (deal.budget_loc.try(:round) || 0)
        budget_usd = (deal.budget.try(:round) || 0)
        member = deal.users.collect{|user| user.name}.join(";")
        csv << [deal.id, deal.name, advertiser_name, agency_name, member, budget_loc, deal.curr_cd, stage_name, stage_probability, get_option(deal, "Deal Type"), get_option(deal, "Deal Source"), deal.next_steps, deal.start_date, deal.end_date, deal.created_at.strftime("%Y-%m-%d"), deal.closed_at, get_option(deal, "Close Reason")]
      end
    end

    products_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Product", "Pricing Type", "Product Line", "Product Family", "Budget", "Period", "Budget USD"]
      all.each do |deal|
        deal.deal_product_budgets.each do |deal_product_budget|
          budget_loc = (deal_product_budget.budget_loc.try(:round) || 0)
          budget_usd = (deal_product_budget.budget.try(:round) || 0)
          product = deal_product_budget.deal_product.product
          product_name = ""
          pricing_type = ""
          product_family = ""
          product_line = ""
          if !product.nil?
            product_name = product.name
            pricing_type = get_option(product, "Pricing Type")
            product_line = get_option(product, "Product Line")
            product_family = get_option(product, "Product Family")
          end
		      csv << [deal.id, deal.name, product_name, pricing_type, product_line, product_family, budget_loc, deal_product_budget.start_date.strftime("%B %Y"), budget_usd]
        end
      end
    end

    deal_stage_logs_csv = CSV.generate do |csv|
      csv << ['Deal ID', 'Name', 'Stage', 'Days in Stage', 'Previous Stage', 'Updated Date', 'Updated By']

      all.each do |deal|
        deal.audit_logs.by_type_of_change(AuditLog::STAGE_CHANGE_TYPE).each do |audit_log|
          stage_updater = User.find(audit_log.updated_by).name

		      csv << [deal.id, deal.name, Stage.find(audit_log.new_value).name, audit_log.biz_days, audit_log.old_value ? Stage.find(audit_log.old_value).name : 'n/a', audit_log.created_at, stage_updater]
        end

        stage_updater1 = deal.stage_updator.name if !deal.stage_updator.nil?
        active_wday = (deal.stage_updated_at.to_date..Time.current.to_date).count {|date| date.wday >= 1 && date.wday <= 5} if !deal.stage_updated_at.nil?

        csv << [deal.id, deal.name, deal.stage.name, active_wday, deal.previous_stage ? deal.previous_stage.name : "n/a", deal.stage_updated_at, stage_updater1]
      end
    end

    filestream = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry("deals-#{Date.today}.csv")
      zio.write deals_csv
      zio.put_next_entry("products-#{Date.today}.csv")
      zio.write products_csv
      zio.put_next_entry("deal-stages-#{Date.today}.csv")
      zio.write deal_stage_logs_csv
    end
    filestream.rewind
    filestream.read

  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    deal_type_field = current_user.company.fields.find_by_name('Deal Type')
    deal_source_field = current_user.company.fields.find_by_name('Deal Source')
    close_reason_field = current_user.company.fields.find_by_name("Close Reason")
    list_of_currencies = Currency.pluck(:curr_cd)
    @custom_field_names = current_user.company.deal_custom_field_names

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'deal', source: 'ui')
    import_log.set_file_source(file_path)

    deal_change = {time_period_ids: [], product_ids: [], stage_ids: [], user_ids: []}

    Deal.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.skip_callback(:destroy, :after, :update_pipeline_fact_callback)

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed
      @has_custom_field_rows ||= (row.headers && @custom_field_names.map(&:to_csv_header)).any?
      if row[0]
        begin
          deal = current_user.company.deals.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          import_log.count_failed
          import_log.log_error(["Deal ID #{row[0]} could not be found"])
          next
        end
      end

      if row[1].nil? || row[1].blank?
        import_log.count_failed
        import_log.log_error(["Deal name can't be blank"])
        next
      end

      if row[2].present?
        advertiser_type_id = Client.advertiser_type_id(current_user.company)
        advertisers = current_user.company.clients.by_type_id(advertiser_type_id).where('name ilike ?', row[2].strip)
        if advertisers.length > 1
          import_log.count_failed
          import_log.log_error(["Advertiser #{row[2]} matched more than one account record"])
          next
        elsif advertisers.length == 0
          import_log.count_failed
          import_log.log_error(["Advertiser #{row[2]} could not be found"])
          next
        else
          advertiser = advertisers.first
        end
      else
        import_log.count_failed
        import_log.log_error(["Advertiser can't be blank"])
        next
      end

      if row[3].present?
        agency_type_id = Client.agency_type_id(current_user.company)
        agencies = current_user.company.clients.by_type_id(agency_type_id).where('name ilike ?', row[3].strip)
        if agencies.length > 1
          import_log.count_failed
          import_log.log_error(["Agency #{row[3]} matched more than one account record"])
          next
        elsif agencies.length == 0
          import_log.count_failed
          import_log.log_error(["Agency #{row[3]} could not be found"])
          next
        else
          agency = agencies.first
        end
      end

      curr_cd = nil
      if row[4]
        curr_cd = row[4].strip
        if !(list_of_currencies.include?(curr_cd))
          import_log.count_failed
          import_log.log_error(["Currency #{curr_cd} is not found"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Currency code can't be blank"])
        next
      end

      if row[5].present?
        deal_type = deal_type_field.options.where('name ilike ?', row[5].strip).first
        unless deal_type
          import_log.count_failed
          import_log.log_error(["Deal Type #{row[5]} could not be found"])
          next
        end
      else
        deal_type = nil
      end

      if row[6].present?
        deal_source = deal_source_field.options.where('name ilike ?', row[6].strip).first
        unless deal_source
          import_log.count_failed
          import_log.log_error(["Deal Source #{row[6]} could not be found"])
          next
        end
      else
        deal_source = nil
      end

      start_date = nil
      if row[7].present?
        if !(row[8].present?)
          import_log.count_failed
          import_log.log_error(['End Date must be present if Start Date is set'])
          next
        end
        begin
          start_date = Date.strptime(row[7], '%m/%d/%Y')
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['Start Date must have valid date format MM/DD/YYYY'])
          next
        end
      end

      end_date = nil
      if row[8].present?
        if !(row[7].present?)
          import_log.count_failed
          import_log.log_error(['Start Date must be present if End Date is set'])
          next
        end
        begin
          end_date = Date.strptime(row[8], '%m/%d/%Y')
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['End Date must have valid date format MM/DD/YYYY'])
          next
        end
      end

      if (end_date && start_date) && start_date > end_date
        import_log.count_failed
        import_log.log_error(['Start Date must preceed End Date'])
        next
      end

      if row[9].present?
        stage = current_user.company.stages.where('name ilike ?', row[9].strip).first
        unless stage
          import_log.count_failed
          import_log.log_error(["Stage #{row[9]} could not be found"])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Stage can't be blank"])
        next
      end

      deal_member_list = []
      if row[11].present?
        deal_members = row[11].split(';').map{|el| el.split('/') }

        deal_member_list_error = false

        deal_members.each do |deal_member|
          if deal_member[1].nil?
            import_log.count_failed
            import_log.log_error(["Deal Member #{deal_member[0]} does not have a share"])
            deal_member_list_error = true
            break
          elsif user = current_user.company.users.where('email ilike ?', deal_member[0]).first
            deal_member_list << user
          else
            import_log.count_failed
            import_log.log_error(["Deal Member #{deal_member[0]} could not be found in the User list"])
            deal_member_list_error = true
            break
          end
        end

        if deal_member_list_error
          next
        end
      else
        import_log.count_failed
        import_log.log_error(["Team can't be blank"])
        next
      end

      if row[12].present?
        begin
          created_at = DateTime.strptime(row[12], '%m/%d/%Y') + 8.hours
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['Deal Creation Date must have valid date format MM/DD/YYYY'])
          next
        end
      end

      if row[13].present?
        begin
          closed_date = DateTime.strptime(row[13], '%m/%d/%Y') + 8.hours
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['Deal Close Date must have valid date format MM/DD/YYYY'])
          next
        end
      else
        closed_date = nil
      end

      if row[14].present?
        close_reason = close_reason_field.options.where('name ilike ?', row[14].strip).first
        unless close_reason
          import_log.count_failed
          import_log.log_error(["Close Reason #{row[14]} could not be found"])
          next
        end
      else
        close_reason = nil
      end

      deal_contact_list = []
      if row[15].present?
        deal_contacts = row[15].split(';')

        deal_contact_list_error = false

        deal_contacts.each do |deal_contact|
          if contact = Contact.by_email(deal_contact, current_user.company_id).first
            deal_contact_list << contact
          else
            import_log.count_failed
            import_log.log_error(["Contact #{deal_contact} could not be found"])
            deal_contact_list_error = true
            break
          end
        end

        if deal_contact_list_error
          next
        end
      end

      closed_reason_text = ''
      if row[16].present?
        closed_reason_text = row[16].strip
      end

      next_steps = nil
      if row[17].present?
        next_steps = row[17].strip
      end

      if row[18].present?
        created_by_user = current_user.company.users.by_email(row[18].strip).first

        if created_by_user
          created_by = created_by_user.id
        else
          import_log.count_failed
          import_log.log_error(["Created By #{row[18].strip} user could not be found"])
        end
      end

      deal_params = {
        name: row[1].strip,
        advertiser: advertiser,
        agency: agency,
        curr_cd: curr_cd,
        start_date: start_date,
        end_date: end_date,
        stage: stage,
        updated_by: current_user.id,
        closed_at: closed_date,
        closed_reason_text: closed_reason_text,
        next_steps: next_steps,
        legacy_id: row[19]&.strip
      }

      deal_params[:created_by] = created_by if created_by
      deal_params[:created_at] = created_at if created_at

      type_value_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: deal_type_field.id,
        option_id: (deal_type ? deal_type.id : nil),
        company_id: current_user.company.id
      }

      source_value_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: deal_source_field.id,
        option_id: (deal_source ? deal_source.id : nil),
        company_id: current_user.company.id
      }

      close_reason_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: close_reason_field.id,
        option_id: (close_reason ? close_reason.id : nil),
        company_id: current_user.company.id
      }

      if !(deal.present?)
        deals = current_user.company.deals.where('name ilike ?', row[1].strip)
        if deals.length > 1
          import_log.count_failed
          import_log.log_error(["Deal name #{row[1]} matched more than one deal record"])
          next
        end
        deal = deals.first
      end

      if deal.present?
        type_value_params[:subject_id] = deal.id
        source_value_params[:subject_id] = deal.id

        if deal_type_value = deal.values.where(field_id: deal_type_field).first
          type_value_params[:id] = deal_type_value.id
        end

        if deal_source_value = deal.values.where(field_id: deal_source_field).first
          source_value_params[:id] = deal_source_value.id
        end

        deal_change[:time_period_ids] += current_user.company.time_period_ids(deal.start_date, deal.end_date)
        deal_change[:stage_ids] += [deal.stage_id] if deal.stage_id.present?
        deal_change[:user_ids] += deal.deal_members.collect{|item| item.user_id}
        deal_change[:product_ids] += deal.deal_products.collect{|item| item.product_id}
      else
        deal = current_user.company.deals.new(created_by: current_user.id)
        deal_is_new = true
      end

      deal_params[:values_attributes] = [
        type_value_params,
        source_value_params,
        close_reason_params
      ]
      if deal.update_attributes(deal_params)
        import_log.count_imported

        if deal_is_new || row[10] == 'Y'
          deal.deal_members.delete_all
        end

        deal_member_list.each_with_index do |user, index|
          deal_member = deal.deal_members.find_or_initialize_by(user: user)
          deal_member.update(share: deal_members[index][1].to_i)
          deal_change[:user_ids] += [user.id]
        end

        deal_change[:time_period_ids] += current_user.company.time_period_ids(start_date, end_date)
        deal_change[:stage_ids] += [stage.id] if stage.present?
        deal_contact_list.each do |contact|
          deal.deal_contacts.find_or_create_by(contact: contact)
        end

        import_deal_custom_field(deal, row) if @has_custom_field_rows
      else
        import_log.count_failed
        import_log.log_error(deal.errors.full_messages)
        next
      end
    end
    Deal.set_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.set_callback(:save, :after, :update_pipeline_fact_callback)
    DealProduct.set_callback(:destroy, :after, :update_pipeline_fact_callback)

    deal_change[:time_period_ids] = deal_change[:time_period_ids].uniq
    deal_change[:user_ids] = deal_change[:user_ids].uniq
    deal_change[:product_ids] = deal_change[:product_ids].uniq
    deal_change[:stage_ids] = deal_change[:stage_ids].uniq

    ForecastPipelineCalculatorWorker.perform_async(deal_change)

    import_log.save
  end

  def update_stage
    self.previous_stage_id = self.stage_id_was
    self.stage_updated_at = updated_at
    self.stage_updated_by = updated_by
  end

  def close_display_product
    should_open = false
    self.deal_products.each do |deal_product|
      if deal_product.product.revenue_type == "Display"
        deal_product.open = false
        deal_product.save
      else
        if deal_product.open == true
          should_open = true
        end
      end
    end
    update_attribute(:open, should_open)
  end

  def recalculate_currency
    deal_product_budgets.update_all("budget = budget_loc / #{self.exchange_rate}")
    deal_products.map{ |deal_product| deal_product.update_budget }
    self.budget = deal_products.sum(:budget)
  end

  def send_ealert
    Email::EalertService.new(self).perform
  end

  def update_close
    if closed_at.nil? && closed_at_was.nil? && stage.closed?
      self.closed_at = updated_at
    end

    self.open = self.should_open?
    Deal::DealCloseService.new(self).perform
  end

  def should_open?
    should_open = stage.open?
    if !stage.open? && stage.probability == 100
      should_open = self.deal_products.product_type_of('Display').count > 0
    end
    should_open
  end

  def send_new_deal_notification
    notification = company.notifications.find_by_name('New Deal')

    if notification.present?
      recipients = notification.recipients_arr

      UserMailer.new_deal_email(recipients, self.id).deliver_later(wait: 10.minutes, queue: 'default') if recipients.any?
    end
  end

  def send_stage_changed_deal_notification
    notification = company.notifications.find_by_name('Stage Changed')

    if notification.present?
      recipients = notification.recipients_arr

      UserMailer.stage_changed_email(recipients, self.id, stage).deliver_later(wait: 10.minutes, queue: 'default') if recipients.any?
    end
  end

  def send_closed_won_deal_notification
    notification = company.notifications.find_by_name('Closed Won')

    if notification.present?
      recipients = notification.recipients_arr

      UserMailer.close_email(recipients, self.id).deliver_later(wait: 10.minutes, queue: 'default') if recipients.any?
    end
  end

  def send_lost_deal_notification
    if stage_id_changed? && closed_lost?
      notification = company.notifications.find_by_name(Notification::LOST_DEAL)
      return if notification.nil?

      recipients = notification.recipients_arr

      UserMailer.lost_deal_email(recipients, self.id).deliver_later(wait: 10.minutes, queue: 'default') if recipients.any?

    end
  end

  def set_deal_status
    should_open = stage.open?
    if !stage.open? && stage.probability == 100
      deal_products.each do |deal_product|
        if deal_product.product.revenue_type != "Content-Fee"
          should_open = true
          deal_product.open = true
        else
          deal_product.open = false
        end
        deal_product.save
      end
    else
      deal_products.each do |deal_product|
        deal_product.open = stage.open
        deal_product.save
      end
    end
    self.open = should_open
    self.save
  end

  def wday_in_stage
    count_wday(stage_updated_at, Time.current) || 0
  end

  def wday_since_opened
    count_wday(created_at, Time.current) || 0
  end

  def count_wday(date1, date2)
    if !date1.nil?
      (date1.to_date..date2.to_date).count {|date| date.wday >= 1 && date.wday <= 5}
    end
  end

  def self.count_wday1(date1, date2)
    if !date1.nil?
      (date1.to_date..date2.to_date).count {|date| date.wday >= 1 && date.wday <= 5}
    end
  end

  def ordered_by_created_at_billing_contacts
    deal_contacts.where(role: 'Billing').order(:created_at)
  end

  def self.grouped_count_by_week(start_date, end_date)
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    .group("date_trunc('day', deals.created_at)")
    .order('date_trunc_day_deals_created_at').count
  end

  def self.grouped_sum_budget_by_week(start_date, end_date)
    where(closed_at: start_date.beginning_of_day..end_date.end_of_day)
    .won
    .select(:closed_at, :budget)
    .group('deals.closed_at')
    .order('deals.closed_at')
    .sum('budget')
  end

  def user_with_highest_share
    @_user_with_highest_share ||= ordered_members_by_share.first.user
  end

  def team_for_user_with_highest_share
    return nil if ordered_members_by_share.blank?

    user_with_highest_share.leader? ? team_leader_name : user_with_highest_share_name
  end

  def team_leader_name
    Team.find_by(leader: user_with_highest_share).name
  end

  def user_with_highest_share_name
    user_with_highest_share.team.name rescue nil
  end

  def ordered_members_by_share
    deal_members.ordered_by_share
  end

  def upsert_custom_fields(params)
    if self.deal_custom_field.present?
      self.deal_custom_field.update(params)
    else
      cf = self.build_deal_custom_field(params)
      cf.save
    end
  end

  def update_pipeline_fact_stage(old_stage_id, new_stage_id)
    company = self.company
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", self.start_date, self.end_date)
    time_periods.each do |time_period|
      self.users.each do |user|
        self.deal_products.each do |deal_product|
          product = deal_product.product
          old_stage = company.stages.find(old_stage_id)
          new_stage = company.stages.find(new_stage_id)
          forecast_pipeline_fact_calculator1 = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, old_stage)
          forecast_pipeline_fact_calculator1.calculate()
          forecast_pipeline_fact_calculator2 = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, new_stage)
          forecast_pipeline_fact_calculator2.calculate()
        end
      end
    end
  end

  def update_pipeline_fact_date(s_date, e_date)
    company = self.company
    stage = self.stage
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", s_date, e_date)
    time_periods.each do |time_period|
      self.users.each do |user|
        self.deal_products.each do |deal_product|
          product = deal_product.product
          forecast_pipeline_fact_calculator = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
          forecast_pipeline_fact_calculator.calculate()
        end
      end
    end
  end

  def updated?
    created_at != updated_at
  end

  def update_pipeline_fact(deal)
    company = deal.company
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", deal.start_date, deal.end_date)
    stage = self.stage
    time_periods.each do |time_period|
      deal.users.each do |user|
        deal.deal_products.each do |deal_product|
          product = deal_product.product
          forecast_pipeline_fact_calculator1 = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
          forecast_pipeline_fact_calculator1.calculate()
        end
      end
    end
  end

  def include_pmp_product?
    self.products.where(revenue_type: 'PMP').count > 0
  end

  def log_budget_changes(current_budget, new_budget)
    AuditLogService.new(
      record: self,
      type: AuditLog::BUDGET_CHANGE_TYPE,
      old_value: current_budget,
      new_value: new_budget,
      changed_amount: (new_budget - current_budget)
    ).perform
  end

  def generate_pmp
    Deal::PmpGenerateService.new(self).perform
  end

  def generate_io
    Deal::IoGenerateService.new(self).perform
  end

  def advertiser_name
    advertiser&.name
  end

  def agency_name
    agency&.name
  end

  def update_associated_search_documents
    PgSearchDocumentUpdateWorker.perform_async('Activity', activities.pluck(:id))
  end

  private

  def generate_io_or_pmp
    include_pmp_product? ? generate_pmp : generate_io
  end

  def self.import_deal_custom_field(deal, row)
    params = {}
    @custom_field_names.each do |cf|
      params[cf.field_name] = row[cf.to_csv_header]
    end

    if params.compact.any?
      deal.upsert_custom_fields(params)
    end
  end

  def connect_deal_clients
    if agency.present? && advertiser.present?
      unless ClientConnection.find_by(agency_id: agency.id, advertiser_id: advertiser.id).present?
        ClientConnection.create(agency_id: agency.id, advertiser_id: advertiser.id)
      end
    end
  end

  def log_start_date_changes
    AuditLogService.new(
      record: self,
      type: AuditLog::START_DATE_CHANGE_TYPE,
      old_value: start_date_was,
      new_value: start_date
    ).perform
  end

  def log_stage_changes
    AuditLogService.new(
      record: self,
      type: AuditLog::STAGE_CHANGE_TYPE,
      old_value: previous_stage_id,
      new_value: stage_id
    ).perform
  end

  def setup_egnyte_folders
    Egnyte::SetupDealFoldersWorker.perform_async(company.egnyte_integration.id, id) if company.egnyte_integration
  end

  def update_egnyte_folder
    return unless company.egnyte_integration && (previous_changes[:name] || previous_changes[:advertiser_id])

    advertiser_changed = previous_changes[:advertiser_id].present?

    Egnyte::UpdateDealFolderWorker.perform_async(company.egnyte_integration.id, id, advertiser_changed)
  end

  def create_hoopla_newsflash_event
    return unless just_switched_to_closed_won? && company.hoopla_configurations.first&.switched_on? && manual_update

    Hoopla::CreateNewsflashEventOnDealWonWorker.perform_async(id, updated_by, company_id)
  end
end
