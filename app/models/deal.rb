require 'rubygems'
require 'zip'

class Deal < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id', counter_cache: :advertiser_deals_count
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id', counter_cache: :agency_deals_count
  belongs_to :stage, counter_cache: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :stage_updator, class_name: 'User', foreign_key: 'stage_updated_by'

  has_many :deal_products
  has_many :products, -> { distinct }, through: :deal_products
  has_many :deal_members
  has_many :users, through: :deal_members
  has_many :values, as: :subject
  has_many :deal_stage_logs
  has_many :activities

  validates :advertiser_id, :start_date, :end_date, :name, :stage_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  before_save do
    if deal_products.empty?
      self.budget = budget.to_i * 100 if budget_changed?
    end
  end

  before_update do
    if stage_id_changed?
      update_stage
      update_close
    end
  end

  after_update do
    reset_products if (start_date_changed? || end_date_changed?)
    log_stage if stage_id_changed?
  end

  before_create do
    update_stage
  end

  after_create do
    generate_deal_members
  end

  before_destroy do
    update_stage
  end

  after_destroy do
    log_stage
  end

  scope :for_client, -> (client_id) { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }
  scope :for_time_period, -> (start_date, end_date) { where('deals.start_date <= ? AND deals.end_date >= ?', end_date, start_date) }
  scope :open, -> { joins(:stage).where('stages.open IS true') }

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    name + ', '+ advertiser.name + ', '+ stage.name
  end

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :stage, :values], methods: [:formatted_name]))
  end

  def as_weighted_pipeline(start_date, end_date)
    {
      name: name,
      client_name: advertiser.name,
      probability: stage.probability,
      budget: budget,
      in_period_amt: in_period_amt(start_date, end_date),
      wday_in_stage: wday_in_stage,
      wday_since_opened: wday_since_opened,
      start_date: self.start_date
    }
  end

  def in_period_amt(start_date, end_date)
    deal_products.for_time_period(start_date, end_date).to_a.sum do |deal_product|
      from = [start_date, deal_product.start_date].max
      to = [end_date, deal_product.end_date].min
      num_days = (to.to_date - from.to_date) + 1
      deal_product.daily_budget * num_days
    end
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def add_product(product_id, total_budget, update_budget = true)
    daily_budget = total_budget.to_f / days
    months.each_with_index do |month, index|
      monthly_budget = daily_budget * days_per_month[index]
      period = Date.new(*month)
      deal_products.create(product_id: product_id, start_date: period, end_date: period.end_of_month, budget: monthly_budget.round(2) * 100)
    end
    update_total_budget if update_budget
  end

  def remove_product(product_id, update_budget = true)
    delete_product = products.find(product_id)
    products.delete(delete_product)
    update_total_budget if update_budget
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

  def update_total_budget
    update_attributes(budget: deal_products.sum(:budget))
  end

  def reset_products
    # This only happens if start_date or end_date has changed on the Deal and thus it has already be touched
    ActiveRecord::Base.no_touching do
      array = []

      products.each do |product|
        old_deal_products = deal_products.where(product_id: product.id)

        total_budget = old_deal_products.sum(:budget) / 100
        old_deal_products.destroy_all
        array << { id: product.id, total_budget: total_budget }
      end

      array.each do |object|
        add_product(object[:id], object[:total_budget], false)
      end
    end
  end

  def generate_deal_members
    # This only gets called on create where the Deal has inherently been touched
    ActiveRecord::Base.no_touching do
      advertiser.client_members.each do |client_member|
        deal_member = deal_members.create(client_member.defaults)

        if client_member.role_value_defaults
          deal_member.values.create(client_member.role_value_defaults)
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

  def self.to_zip
    deals_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Advertiser", "Agency", "Team Member", "Budget", "Stage", "Probability", "Type", "Source", "Next Steps", "Start Date", "End Date", "Created Date", "Closed Date", "Close Reason"]
      all.each do |deal|
        agency_name = !deal.agency.nil? ? deal.agency.name : nil
        budget = !deal.budget.nil? ? deal.budget/100.0 : nil
        member = !deal.creator.nil? ? deal.creator.name : nil
        csv << [deal.id, deal.name, deal.advertiser.name, agency_name, member, budget, deal.stage.name, deal.stage.probability, deal.deal_type, deal.source_type, deal.next_steps, deal.start_date, deal.end_date, deal.created_at, deal.closed_at, get_option(deal, "Close Reason")]
      end
    end

    products_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Product", "Pricing Type", "Product Line", "Product Family", "Budget", "Period"]
      all.each do |deal|
        deal.deal_products.each do |deal_product|
          budget = !deal_product.budget.nil? ? deal_product.budget/100.0 : nil
          product = deal_product.product
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
		      csv << [deal.id, deal.name, product_name, pricing_type, product_line, product_family, budget, deal_product.start_date.strftime("%B %Y")]
        end
      end
    end

    deal_stage_logs_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Stage", "Days in Stage", "Updated Date", "Updated By"]
      all.each do |deal|
        deal.deal_stage_logs.each do |deal_stage_log|
          stage_updator = deal_stage_log.stage_updator.name if !deal_stage_log.stage_updator.nil?
		      csv << [deal.id, deal.name, deal_stage_log.stage.name, deal_stage_log.active_wday, deal_stage_log.stage_updated_at, stage_updator]
        end
        stage_updator1 = deal.stage_updator.name if !deal.stage_updator.nil?
        active_wday = (deal.stage_updated_at.to_date..Time.current.to_date).count {|date| date.wday >= 1 && date.wday <= 5} if !deal.stage_updated_at.nil?
        csv << [deal.id, deal.name, deal.stage.name, active_wday, deal.stage_updated_at, stage_updator1]
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

  def update_stage
    self.stage_updated_at = updated_at
    self.stage_updated_by = updated_by
  end

  def log_stage
    if company.present? && stage_id_was.present? && stage_updated_by_was.present? && stage_updated_at_was.present?
      deal_stage_logs.create(company_id: company.id, stage_id: stage_id_was, stage_updated_by: stage_updated_by_was, stage_updated_at: stage_updated_at_was, active_wday: count_wday(stage_updated_at_was, stage_updated_at))
    end
  end

  def update_close
    if !stage.open? && stage.probability == 100
      notification = company.notifications.find_by_name('Closed Won')
      if !notification.nil? && !notification.recipients.nil?
        recipients = notification.recipients.split(',').map(&:strip)
        if !recipients.nil? && recipients.length > 0
          subject = 'A '+(budget.nil? ? '$0' : ActiveSupport::NumberHelper.number_to_currency(budget/100, :precision => 0))+' deal for '+advertiser.name+' was just won!'
          UserMailer.close_email(recipients, subject, self).deliver_later
        end
      end
    else
      self.closed_at = updated_at if !stage.open?
      if !self.closed_at.nil?
        self.closed_at = nil
        if !self.fields.nil? && !self.values.nil?
          field = self.fields.find_by_name("Close Reason")
          close_reason = self.values.find_by_field_id(field.id) if !field.nil?
          close_reason.destroy if !close_reason.nil?
        end
      end
      notification = company.notifications.find_by_name('Stage Changed')
      if !notification.nil? && !notification.recipients.nil?
        recipients = notification.recipients.split(',').map(&:strip)
        if !recipients.nil? && recipients.length > 0
          subject = self.name + ' changed to ' + stage.name
          UserMailer.stage_changed_email(recipients, subject, self).deliver_later
        end
      end      
    end
  end

  def wday_in_stage
    count_wday(stage_updated_at, Time.current)
  end

  def wday_since_opened
    count_wday(created_at, Time.current)
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

end
