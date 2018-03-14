class Company < ActiveRecord::Base
  include CompanyMappings

  has_many :users
  has_many :clients
  has_many :contacts, inverse_of: :company
  has_many :revenues
  has_many :deals
  has_many :deal_products, through: :deals
  has_many :deal_product_budgets, through: :deal_products
  has_many :contracts
  has_many :stages
  has_many :distinct_stages, -> {distinct}, class_name: 'Stage'
  has_many :products
  has_many :product_families
  has_many :teams
  has_many :time_periods
  has_many :quotas
  has_many :fields
  has_many :notifications
  has_many :activities
  has_many :activity_types
  has_many :ios
  has_many :costs, through: :ios
  has_many :cost_monthly_amounts, through: :costs
  has_many :content_fees, through: :ios
  has_many :content_fee_product_budgets, through: :content_fees
  has_many :pmps
  has_many :pmp_items, through: :pmps
  has_many :pmp_item_daily_actuals, through: :pmp_items
  has_many :display_line_items, through: :ios
  has_many :display_line_item_budgets, through: :display_line_items
  has_many :temp_ios
  has_many :bps
  has_many :assets, dependent: :destroy
  has_many :ealerts, dependent: :destroy
  has_many :bp_estimates, through: :bps
  has_many :deal_custom_field_names
  has_many :deal_product_cf_names
  has_many :account_cf_names
  has_many :contact_cf_names
  has_many :deal_custom_fields, through: :deals
  has_many :deal_product_cfs, through: :deal_products
  has_many :account_cfs, through: :clients
  has_many :contact_cfs, through: :contacts
  has_many :exchange_rates
  has_many :validations, dependent: :destroy
  has_many :api_configurations, dependent: :destroy
  has_many :dfp_api_configurations, dependent: :destroy
  has_many :operative_api_configurations, dependent: :destroy
  has_many :operative_datafeed_configurations, dependent: :destroy
  has_many :asana_connect_configurations, dependent: :destroy
  has_many :google_sheets_configurations, dependent: :destroy
  has_many :initiatives, dependent: :destroy
  has_many :integration_logs, dependent: :destroy
  has_many :requests
  has_many :influencers, dependent: :destroy
  has_many :influencer_content_fees, through: :influencers
  has_many :audit_logs
  has_many :filter_queries
  has_many :publisher_stages, dependent: :destroy
  has_many :sales_stages, dependent: :destroy
  has_many :publishers, dependent: :destroy
  has_many :publisher_custom_field_names, dependent: :destroy
  has_many :publisher_custom_fields, through: :publishers
  has_many :ssp_advertisers
  has_many :sales_processes

  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'

  has_one :billing_address, as: :addressable, class_name: 'Address'
  has_one :physical_address, as: :addressable, class_name: 'Address'

  serialize :forecast_permission, HashSerializer

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :physical_address
  accepts_nested_attributes_for :assets

  before_create :setup_defaults

  def setup_defaults
    client_type = fields.find_or_initialize_by(subject_type: 'Client', name: 'Client Type', value_type: 'Option', locked: true)
    setup_default_options(client_type, %w(Advertiser Agency))

    contact_role = fields.find_or_initialize_by(subject_type: 'Deal', name: 'Contact Role', value_type: 'Option', locked: true)
    setup_default_options(contact_role, ['Billing'])

    fields.find_or_initialize_by(subject_type: 'Deal', name: 'Deal Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Deal', name: 'Deal Source', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Deal', name: 'Close Reason', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Pricing Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Product Line', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Product Family', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Client', name: 'Member Role', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Client', name: 'Category', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Client', name: 'Region', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Client', name: 'Segment', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contact', name: 'Job Level', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Multiple', name: 'Attachment Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Influencer', name: 'Network', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Publisher', name: 'Publisher Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Publisher', name: 'Renewal Terms', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Publisher', name: 'Member Role', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Status', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Member Role', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Contact Role', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Special Term Name', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Contract', name: 'Special Term Type', value_type: 'Option', locked: true)
    cost_type = fields.find_or_initialize_by(subject_type: 'Cost', name: 'Cost Type', value_type: 'Option', locked: true)
    setup_default_options(cost_type, ['General'])

    notifications.find_or_initialize_by(name: 'Closed Won', active: true)
    notifications.find_or_initialize_by(name: 'Stage Changed', active: true)
    notifications.find_or_initialize_by(name: 'New Deal', active: true)
    notifications.find_or_initialize_by(name: 'Lost Deal', active: true)
    notifications.find_or_initialize_by(name: 'Pipeline Changes Reports', active: true)
    notifications.find_or_initialize_by(name: Notification::PMP_STOPPED_RUNNING, active: true)

    setup_default_activity_types

    ealerts.find_or_initialize_by(recipients: nil, automatic_send: false, same_all_stages: true)

    setup_default_validations
  end

  def settings
    [
      { name: 'Deals', fields: fields.where(subject_type: 'Deal') },
      { name: 'Accounts', fields: fields.where(subject_type: 'Client') },
      { name: 'Products', fields: fields.where(subject_type: 'Product') },
      { name: 'Contacts', fields: fields.where(subject_type: 'Contact') },
      { name: 'Multiple', fields: fields.where(subject_type: 'Multiple') },
      { name: 'Influencers', fields: fields.where(subject_type: 'Influencer') },
      { name: 'Publishers', fields: fields.where(subject_type: 'Publisher') },
      { name: 'Contracts', fields: fields.where(subject_type: 'Contract') },
      { name: 'Costs', fields: fields.where(subject_type: 'Cost') }
    ]
  end

  def teams_tree
    self.class.teams_tree_for(self)
  end

  def self.teams_tree_for(instance)
    Team.where("teams.id IN (#{teams_tree_sql(instance)})")
  end

  def self.teams_tree_sql(instance)
    sql = <<-SQL
      WITH RECURSIVE team_tree(id, path) AS (
          SELECT teams.id, ARRAY[teams.id]
          FROM companies
          JOIN teams ON teams.company_id = companies.id
          WHERE companies.id = #{instance.id}
        UNION ALL
          SELECT teams.id, path || teams.id
          FROM team_tree
          JOIN teams ON teams.parent_id = team_tree.id
          WHERE NOT teams.id = ANY(path)
      )
      SELECT id FROM team_tree ORDER BY path
    SQL
  end

  def teams_tree_members
    self.class.teams_tree_members_for(self)
  end

  def all_sales_reps
    users.by_user_type([SELLER, SALES_MANAGER])
  end

  def self.teams_tree_members_for(instance)
    User.where("users.id IN (#{teams_tree_members_sql(instance)})")
  end

  def self.teams_tree_members_sql(instance)
    sql = <<-SQL
      WITH RECURSIVE team_tree(id, path) AS (
          SELECT users.id, ARRAY[users.id]
          FROM users
          WHERE users.company_id = #{instance.id}
        UNION ALL
          SELECT users.id, path || users.id
          FROM team_tree
          JOIN teams ON teams.leader_id = team_tree.id
          JOIN users ON users.team_id = teams.id
          WHERE NOT users.id = ANY(path)
      )
      SELECT id FROM team_tree ORDER BY path
    SQL
  end

  def has_exchange_rate_for(curr_cd)
    rates = exchange_rates.where(currency: Currency.find_by(curr_cd: curr_cd)).where('start_date <= ? AND end_date >= ?', Date.today, Date.today)
    return true if rates.length == 1
  end

  def active_currencies
    rates = exchange_rates.where('start_date <= ? AND end_date >= ?', Date.today, Date.today).includes(:currency)
    rates.map(&:currency).map(&:curr_cd) << 'USD'
  end

  def exchange_rate_for(at_date: Date.today, currency:)
    return 1 if currency == 'USD'
    self.exchange_rates
        .where(currency: Currency.find_by(curr_cd: currency))
        .where('start_date <= ? AND end_date >= ?', at_date, at_date)
        .first
        &.rate
  end

  def operative_api_config
    OperativeApiConfiguration.find_by(company_id: self)
  end

  def validation_for(factor)
    self.validations.find_by(factor: factor.to_s.humanize.titleize)
  end

  def validations_for(object)
    self.validations.where(object: object.to_s.humanize.titleize)
  end

  def all_team_members_and_leaders_ids
    teams.pluck(:leader_id) + users.in_a_team.ids
  end

  def default_sales_process
    sales_processes.first
  end
  
  protected

  def setup_default_options(field, names)
    names.each do |name|
      field.options.find_or_initialize_by(name: name, company: self, locked: true)
    end
  end

  def setup_default_validations
    validations.find_or_initialize_by(factor: 'Disable Deal Won', value_type: 'Boolean')
    validations.find_or_initialize_by(factor: 'Billing Contact Full Address', value_type: 'Boolean')
    validations.find_or_initialize_by(factor: 'Restrict Deal Reopen', value_type: 'Boolean')
    validations.find_or_initialize_by(factor: 'Require Won Reason', value_type: 'Boolean')

    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_category_id')
    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_subcategory_id')
    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_region_id')
    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'client_segment_id')
    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'phone')
    validations.find_or_initialize_by(object: 'Advertiser Base Field', value_type: 'Boolean', factor: 'website')

    validations.find_or_initialize_by(object: 'Agency Base Field',     value_type: 'Boolean', factor: 'client_region_id')
    validations.find_or_initialize_by(object: 'Agency Base Field',     value_type: 'Boolean', factor: 'client_segment_id')
    validations.find_or_initialize_by(object: 'Agency Base Field',     value_type: 'Boolean', factor: 'phone')
    validations.find_or_initialize_by(object: 'Agency Base Field',     value_type: 'Boolean', factor: 'website')

    validations.find_or_initialize_by(object: 'Deal Base Field', value_type: 'Boolean', factor: 'deal_type_value')
    validations.find_or_initialize_by(object: 'Deal Base Field', value_type: 'Boolean', factor: 'deal_source_value')
    validations.find_or_initialize_by(object: 'Deal Base Field', value_type: 'Boolean', factor: 'agency')
    validations.find_or_initialize_by(object: 'Deal Base Field', value_type: 'Boolean', factor: 'next_steps')
  end

  def setup_default_activity_types
    activity_types.find_or_initialize_by(name:'Initial Meeting', action:'had initial meeting with', icon:'/assets/icons/meeting.png', css_class: 'bstr-initial-meeting', position: 1)
    activity_types.find_or_initialize_by(name:'Pitch', action:'pitched to', icon:'/assets/icons/pitch.png', css_class: 'bstr-pitch', position: 2)
    activity_types.find_or_initialize_by(name:'Proposal', action:'sent proposal to', icon:'/assets/icons/proposal.png', css_class: 'bstr-proposal', position: 3)
    activity_types.find_or_initialize_by(name:'Feedback', action:'received feedback from', icon:'/assets/icons/feedback.png', css_class: 'bstr-feedback', position: 4)
    activity_types.find_or_initialize_by(name:'Agency Meeting', action:'had agency meeting with', icon:'/assets/icons/agency-meeting.png', css_class: 'bstr-agency-meeting', position: 5)
    activity_types.find_or_initialize_by(name:'Client Meeting', action:'had client meeting with', icon:'/assets/icons/client-meeting.png', css_class: 'bstr-client-meeting', position: 6)
    activity_types.find_or_initialize_by(name:'Entertainment', action:'had client entertainment with', icon:'/assets/icons/entertainment.png', css_class: 'bstr-entertainment', position: 7)
    activity_types.find_or_initialize_by(name:'Campaign Review', action:'reviewed campaign with', icon:'/assets/icons/campaign-review.png', css_class: 'bstr-campaign-review', position: 8)
    activity_types.find_or_initialize_by(name:'QBR', action:'Quarterly Business Review with', icon:'/assets/icons/qbr.png', css_class: 'bstr-qbr', position: 9)
    activity_types.find_or_initialize_by(name:'Email', action:'emailed to', icon:'/assets/icons/email.png', css_class: 'bstr-email', editable: false, position: 10)
    activity_types.find_or_initialize_by(name:'Post Sale Meeting', action:'had post sale meeting with', icon:'/assets/icons/post-sale.png', css_class: 'bstr-post-sale-meeting', position: 11)
    activity_types.find_or_initialize_by(name:'Internal Meeting', action:'had internal meeting with', icon:'/assets/icons/internal-meeting.png', css_class: 'bstr-internal-meeting', position: 12)
  end
end
