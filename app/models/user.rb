class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :company
  belongs_to :team, counter_cache: :members_count
  has_many :client_members
  has_many :clients, -> (user) { where(company_id: user.company_id) }, through: :client_members
  has_many :revenues, -> (user) { where(company_id: user.company_id) }, through: :clients
  has_many :deal_members
  has_many :io_members
  has_many :pmp_members
  has_many :deals, -> (user) { where(company_id: user.company_id) }, through: :deal_members
  has_many :ios, -> (user) { where(company_id: user.company_id) }, through: :io_members
  has_many :pmps, -> (user) { where(company_id: user.company_id) }, through: :pmp_members
  has_many :quotas, -> (user) { where(company_id: user.company_id) }
  has_many :teams, -> (user) { where(company_id: user.company_id) }, foreign_key: :leader_id
  has_many :team_members, -> (user) { where(company_id: user.company_id) }, through: :teams, source: :members
  has_many :snapshots, -> (user) { where(company_id: user.company_id) }
  has_many :activities
  has_many :reminders
  has_many :contacts, through: :activities
  has_many :display_line_items, through: :ios
  has_many :audit_logs
  has_many :filter_queries
  has_many :email_threads
  has_many :publisher_members, dependent: :destroy
  has_many :publishers, through: :publisher_members

  ROLES = %w(user admin superadmin supportadmin)

  validates :first_name, :last_name, presence: true
  validate :currency_exists

  scope :by_user_type, -> type_id { where(user_type: type_id) if type_id.present? }
  scope :by_name, -> name { where('users.first_name ilike ? or users.last_name ilike ?', "%#{name}%", "%#{name}%") if name.present? }
  scope :by_email, -> email { where('email ilike ?', email)  }
  scope :active, -> { where(is_active: true) }
  scope :without_fake_type, -> { where.not(user_type: FAKE_USER) }
  scope :in_a_team, -> { where.not(team_id: nil) }

  after_create do
    create_dimension
    update_forecast_fact_callback
  end

  after_destroy do |user_record|
    delete_dimension(user_record)
  end


  def create_dimension
    UserDimension.create(
      id: self.id,
      company_id: self.company_id,
      team_id: self.team_id
    )
  end

  def delete_dimension(user_record)
    UserDimension.destroy(user_record.id)
    ForecastPipelineFact.destroy_all(user_dimension_id: user_record.id)
    ForecastRevenueFact.destroy_all(user_dimension_id: user_record.id)
  end

  def update_forecast_fact_callback
    if company.present?
      time_period_ids = company.time_periods.collect{|time_period| time_period.id}
      user_ids = [self.id]
      product_ids = company.products.collect{|product| product.id}
      stage_ids = company.stages.collect{|stage| stage.id}
      io_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids}
      deal_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids, stage_ids: stage_ids}
      ForecastRevenueCalculatorWorker.perform_async(io_change)
      ForecastPipelineCalculatorWorker.perform_async(deal_change)
    end
  end

  def roles=(roles)
    if roles. nil?
      roles = %w(user)
    end
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end

  def authorized_switch_to?(to_user)
    is?(:supportadmin) || is?(:superadmin) || is?(:admin) && to_user && company_id == to_user.company_id
  end

  def company_influencer_enabled
    self.company.influencer_enabled
  end

  def company_publisher_enabled
    self.company.publishers_enabled
  end

  def company_forecast_gap_to_quota_positive
    self.company.forecast_gap_to_quota_positive
  end

  def company_net_forecast_enabled
    self.company.enable_net_forecasting
  end

  def is_admin
    is?(:admin)
  end

  def add_role(role)
    if !is?(role)
      self.roles_mask += 2**ROLES.index(role)
    end
  end

  def remove_role(role)
    if is?(role)
      self.roles_mask -= 2**ROLES.index(role)
    end
  end

  def authenticate(unencrypted_password)
    BCrypt::Password.new(encrypted_password).is_password?(unencrypted_password) && self
  end

  def to_token_payload
    {
      sub: self.id,
      refresh: Digest::SHA1.hexdigest(self.encrypted_password.slice(20, 20))
    }
  end

  def self.from_token_payload payload
    # Returns a valid user, `nil` or raise from token payload
    if user = self.find_by(id: payload["sub"], is_active: true)
      return user if payload["refresh"] && Digest::SHA1.hexdigest(user.encrypted_password.slice(20, 20)) == payload["refresh"]
    end
  end

  def self.from_token_request request
    # Finds user from token request
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by(email: email, is_active: true)
  end

  def has_requests_access?
    revenue_requests_access
  end

  def name
    "#{first_name} #{last_name}"
  end

  def leader?
    teams.count > 0
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.merge(
        include: {
          team: {
            only: [:id, :name]
          },
          teams: {}
        },
        methods: [
          :name,
          :leader?,
          :is_admin,
          :roles,
          :company_influencer_enabled,
          :company_forecast_gap_to_quota_positive,
          :company_net_forecast_enabled,
          :has_forecast_permission
        ]
      ).except(:override))
    end
  end

  def active_for_authentication?
    super && self.is_active?
  end

  def inactive_message
    self.is_active? ? super : :inactive
  end

  def is_active?
    is_active
  end

  def has_forecast_permission
    self.company.forecast_permission[self.user_type.to_s]
  end

  def all_deals_for_time_period(start_date, end_date)
    deals.where(open: true).for_time_period(start_date, end_date)
  end

  def all_ios_for_time_period(start_date, end_date)
    ios.for_time_period(start_date, end_date)
  end

  def set_alert(should_save=false)
    member_ids = [self.id]

    if self.leader?
      self.teams.each do |t|
        member_ids += t.all_members.collect{|m| m.id}
        member_ids += t.all_leaders.collect{|m| m.id}
      end
    end

    member_ids = member_ids.uniq

    io_ids = Io.joins(:io_members).where("io_members.user_id in (?)", member_ids).all.collect{|io| io.id}.uniq

    DisplayLineItem.where("io_id in (?)", io_ids).each do |display|
      if display.balance > 0
        self.pos_balance_cnt += 1
        self.pos_balance += display.balance
      elsif display.balance < 0
        self.neg_balance_cnt += 1
        self.neg_balance += display.balance
      end
    end

    self.pos_balance_l_cnt = self.pos_balance_cnt
    self.pos_balance_l = self.pos_balance
    self.neg_balance_l_cnt = self.neg_balance_cnt
    self.neg_balance_l = self.neg_balance
    self.last_alert_at = DateTime.now
    self.save if should_save
  end

  def currency_exists
    if default_currency.present? && Currency.find_by(curr_cd: default_currency).nil?
      errors.add(:default_currency, "currency does not exist")
    end
  end

  def quarterly_ios(start_date, end_date)
    ios = self.all_ios_for_time_period(start_date, end_date).as_json
    year = start_date.year
    ios.map do |io|
      io_obj = Io.find(io['id'])

      sum_period_budget, split_period_budget = io_obj.for_forecast_page(start_date, end_date, self)

      start_month = start_date.month
      end_month = end_date.month
      io[:quarters] = Array.new(4, nil)
      io[:months] = Array.new(12, nil)
      for i in start_month..end_month
        io[:months][i - 1] = 0
      end
      for i in ((start_month - 1) / 3)..((end_month - 1) / 3)
        io[:quarters][i] = 0
      end
      io[:members] = io_obj.io_members

      if io['end_date'] == io['start_date']
        io['end_date'] += 1.day
      end

      io_obj.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
        month = content_fee_product_budget.start_date.mon
        io[:months][month - 1] += content_fee_product_budget.budget
        io[:quarters][(month - 1) / 3] += content_fee_product_budget.budget
      end

      if self.company.enable_net_forecasting
        io_obj.cost_monthly_amounts.for_time_period(start_date, end_date).each do |cost_monthly_amount|
          month = cost_monthly_amount.start_date.mon
          io[:months][month - 1] -= cost_monthly_amount.budget
          io[:quarters][(month - 1) / 3] -= cost_monthly_amount.budget
        end
      end

      io_obj.display_line_items.for_time_period(start_date, end_date).each do |display_line_item|
        display_line_item_budgets = display_line_item.display_line_item_budgets.to_a

        for index in start_date.mon..end_date.mon
          month = index.to_s
          if index < 10
            month = '0' + index.to_s
          end
          first_date = Date.parse("#{year}#{month}01")

          num_of_days = [[first_date.end_of_month, display_line_item.end_date].min - [first_date, display_line_item.start_date].max + 1, 0].max.to_f
          in_budget_days = 0
          in_budget_total = 0
          display_line_item_budgets.each do |display_line_item_budget|
            in_from = [first_date, display_line_item.start_date, display_line_item_budget.start_date].max
            in_to = [first_date.end_of_month, display_line_item.end_date, display_line_item_budget.end_date].min
            in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
            in_budget_days += in_days
            in_budget_total += display_line_item_budget.daily_budget * in_days
          end
          budget = in_budget_total + display_line_item.ave_run_rate * (num_of_days - in_budget_days)
          io[:months][index - 1] += budget
          io[:quarters][(index - 1) / 3] += budget
        end
      end

      io['in_period_amt'] = sum_period_budget
      io['in_period_split_amt'] = split_period_budget
    end

    ios
  end

  def quarterly_product_ios(product_ids, start_date, end_date)
    data = []
    ios = self.all_ios_for_time_period(start_date, end_date).as_json
    year = start_date.year
    ios.each do |io|
      io_obj = Io.find(io['id'])

      io[:members] = io_obj.io_members.as_json

      if io['end_date'] == io['start_date']
        io['end_date'] += 1.day
      end

      product_ios = {}

      content_fee_rows = io_obj.content_fees
      content_fee_rows = content_fee_rows.for_product_ids(product_ids) if product_ids.present?
      content_fee_rows.each do |content_fee|
        content_fee.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
          item_product_id = content_fee.product_id
          if product_ios[item_product_id].nil?
            product_ios[item_product_id] = JSON.parse(JSON.generate(io))
            product_ios[item_product_id][:product_id] = item_product_id
            product_ios[item_product_id][:product] = content_fee.product
          end
        end
      end

      if self.company.enable_net_forecasting
        cost_rows = io_obj.costs
        cost_rows = cost_rows.for_product_ids(product_ids) if product_ids.present?
        cost_rows.each do |cost|
          cost.cost_monthly_amounts.for_time_period(start_date, end_date).each do |cost_monthly_amount|
            item_product_id = cost.product_id
            if product_ios[item_product_id].nil?
              product_ios[item_product_id] = JSON.parse(JSON.generate(io))
              product_ios[item_product_id][:product_id] = item_product_id
              product_ios[item_product_id][:product] = cost.product
            end
          end
        end
      end

      display_line_item_rows = io_obj.display_line_items.for_time_period(start_date, end_date)
      display_line_item_rows = display_line_item_rows.for_product_ids(product_ids) if product_ids.present?
      display_line_item_rows.each do |display_line_item|
        item_product_id = display_line_item.product_id
        if product_ios[item_product_id].nil?
          product_ios[item_product_id] = JSON.parse(JSON.generate(io))
          product_ios[item_product_id][:product_id] = item_product_id
          product_ios[item_product_id][:product] = display_line_item.product
        end
      end
      product_ios.each do |index, item|
        sum_period_budget, split_period_budget = io_obj.for_product_forecast_page(item[:product], start_date, end_date, self)
        product_ios[index]['in_period_amt'] = sum_period_budget
        product_ios[index]['in_period_split_amt'] = split_period_budget
      end

      data = data + product_ios.values
    end

    data
  end

  def all_revenues_for_time_period(start_date, end_date)
    rs = revenues.for_time_period(start_date, end_date)
    rs.map {|r| r.set_period_budget(start_date, end_date)}
    return rs
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
          FROM users
          JOIN teams ON teams.leader_id = users.id
          WHERE users.id = #{instance.id}
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

  def self.teams_tree_members_for(instance)
    where("users.id IN (#{teams_tree_members_sql(instance)})")
  end

  def self.teams_tree_members_sql(instance)
    sql = <<-SQL
      WITH RECURSIVE team_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM users
          WHERE id = #{instance.id}
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

  def all_team_members
    all_team_members = []
    if self.leader?
      self.teams.each do |team_item|
        all_team_members += team_item.all_members
      end
    elsif self.team.present?
      all_team_members += self.team.all_members
    end
    all_team_members
  end

  def open_deals(start_date, end_date)
    @open_deals ||= self.deals.where(open: true).for_time_period(start_date, end_date).includes(:deal_product_budgets, :stage).to_a
  end

  def number_of_days(start_date, end_date, comparer)
    from = [start_date, comparer.start_date].max
    to = [end_date, comparer.end_date].min
    [(to.to_date - from.to_date) + 1, 0].max
  end

  def all_activities
    members = teams_tree_members
    activity_ids = self.activities.pluck(:id)

    activity_ids += Activity.where(company_id: self.company_id).where(
      deal_id: Deal.joins(:deal_members).where(:deal_members => { :user_id => members })
    ).pluck(:id)

    activity_ids += Activity.where(company_id: self.company_id).where(
      client_id: Client.joins(:client_members).where(:client_members => { :user_id => members })
    ).pluck(:id)

    Activity.where(id: activity_ids)
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end
end
