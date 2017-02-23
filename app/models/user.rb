class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :company
  belongs_to :team, -> (user) { where(company_id: user.company_id) }, counter_cache: :members_count
  has_many :client_members
  has_many :clients, -> (user) { where(company_id: user.company_id) }, through: :client_members
  has_many :revenues, -> (user) { where(company_id: user.company_id) }, through: :clients
  has_many :deal_members
  has_many :io_members
  has_many :deals, -> (user) { where(company_id: user.company_id) }, through: :deal_members
  has_many :ios, -> (user) { where(company_id: user.company_id) }, through: :io_members
  has_many :quotas, -> (user) { where(company_id: user.company_id) }
  has_many :teams, -> (user) { where(company_id: user.company_id) }, foreign_key: :leader_id
  has_many :team_members, -> (user) { where(company_id: user.company_id) }, through: :teams, source: :members
  has_many :snapshots, -> (user) { where(company_id: user.company_id) }
  has_many :activities
  has_many :reminders
  has_many :contacts, through: :activities
  has_many :display_line_items, through: :ios

  before_update do
    modify_admin_status if user_type_changed?
  end

  ROLES = %w(user admin superadmin)

  validates :first_name, :last_name, presence: true
  validate :currency_exists

  scope :by_user_type, -> type_id { where(user_type: type_id) if type_id.present? }
  scope :by_name, -> name { where('users.first_name ilike ? or users.last_name ilike ?', "%#{name}%", "%#{name}%") if name.present? }

  def roles=(roles)
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

  def modify_admin_status
    if user_type == ADMIN
      add_role('admin')
    else
      remove_role('admin')
    end
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
    if user = self.find(payload["sub"])
      return user if payload["refresh"] && Digest::SHA1.hexdigest(user.encrypted_password.slice(20, 20)) == payload["refresh"]
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def leader?
    teams.count > 0
  end

  def leader
    teams.count > 0
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.merge(
        methods: [:name, :leader?, :leader]
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

  def crevenues(start_date, end_date)
    return @crevenues if defined?(@crevenues)
    @crevenues = []
    sum_budget = 0
    sum_period_budget = 0
    split_budget = 0
    split_period_budget = 0
    self.all_ios_for_time_period(start_date, end_date).each do |io|
      io_member = io.io_members.find_by(user_id: self.id)
      share = io_member.share
      io.content_fees.each do |content_fee|
        content_fee.content_fee_product_budgets.each do |content_fee_product_budget|
          sum_budget += content_fee_product_budget.budget
          if (start_date <= content_fee_product_budget.end_date && end_date >= content_fee_product_budget.start_date)
            in_period_days = [[end_date, content_fee_product_budget.end_date].min - [start_date, content_fee_product_budget.start_date].max + 1, 0].max
            in_period_effective_days = [[end_date, content_fee_product_budget.end_date, io_member.to_date].min - [start_date, content_fee_product_budget.start_date, io_member.from_date].max + 1, 0].max
            sum_period_budget += content_fee_product_budget.daily_budget * in_period_days
            split_period_budget += content_fee_product_budget.daily_budget * in_period_effective_days * share / 100
          end
          effective_days = [[content_fee_product_budget.end_date, io_member.to_date].min - [content_fee_product_budget.start_date, io_member.from_date].max + 1, 0].max
          split_budget += content_fee_product_budget.daily_budget * effective_days * share / 100
        end
      end
      # io.display_line_items.each do |display_line_item|
      #   sum_budget += display_line_item.budget
      #   if (start_date <= display_line_item.end_date && end_date >= display_line_item.start_date)
      #     in_period_days = [[end_date, display_line_item.end_date].min - [start_date, display_line_item.start_date].max + 1, 0].max
      #     in_period_effective_days = [[end_date, display_line_item.end_date, io_member.to_date].min - [start_date, display_line_item.start_date, io_member.from_date].max + 1, 0].max
      #     sum_period_budget += display_line_item.ave_run_rate * in_period_days
      #     split_period_budget += display_line_item.ave_run_rate * in_period_effective_days * share / 100
      #   end
      #   effective_days = [[display_line_item.end_date, io_member.to_date].min - [display_line_item.start_date, io_member.from_date].max + 1, 0].max
      #   split_budget += display_line_item.ave_run_rate * effective_days * share / 100
      # end
      io.display_line_items.each do |display_line_item|
        sum_budget += display_line_item.budget
        in_budget_in_period_days = 0
        in_budget_in_period_total = 0
        in_budget_in_period_effective_days = 0
        in_budget_in_period_effective_total = 0
        in_budget_effective_days = 0
        in_budget_effective_total = 0
        display_line_item.display_line_item_budgets.each do |display_line_item_budget|
          if (start_date <= display_line_item_budget.end_date && end_date >= display_line_item_budget.start_date)
            in_budget_in_period_days += [[end_date, display_line_item.end_date, display_line_item_budget.end_date].min - [start_date, display_line_item.start_date, display_line_item_budget.start_date].max + 1, 0].max
            in_budget_in_period_effective_days += [[end_date, display_line_item.end_date, display_line_item_budget.end_date, io_member.to_date].min - [start_date, display_line_item.start_date, display_line_item_budget.start_date, io_member.from_date].max + 1, 0].max
            in_budget_in_period_total += display_line_item_budget.daily_budget * in_budget_in_period_days
            in_budget_in_period_effective_total += display_line_item_budget.daily_budget * in_budget_in_period_effective_days * share / 100
          end
          in_budget_effective_days += [[display_line_item.end_date, io_member.to_date, display_line_item_budget.end_date].min - [display_line_item.start_date, io_member.from_date, display_line_item_budget.start_date].max + 1, 0].max
          in_budget_effective_total += display_line_item_budget.daily_budget * in_budget_in_period_days * share / 100
        end
        if (start_date <= display_line_item.end_date && end_date >= display_line_item.start_date)
          in_period_days = [[end_date, display_line_item.end_date].min - [start_date, display_line_item.start_date].max + 1, 0].max
          in_period_effective_days = [[end_date, display_line_item.end_date, io_member.to_date].min - [start_date, display_line_item.start_date, io_member.from_date].max + 1, 0].max
          sum_period_budget += in_budget_in_period_effective_days + display_line_item.ave_run_rate * (in_period_days - in_budget_in_period_days)
          split_period_budget += in_budget_in_period_effective_total + display_line_item.ave_run_rate * (in_period_effective_days - in_budget_in_period_effective_days) * share / 100
        end
        effective_days = [[display_line_item.end_date, io_member.to_date].min - [display_line_item.start_date, io_member.from_date].max + 1, 0].max
        split_budget += in_budget_effective_total + display_line_item.ave_run_rate * (effective_days - in_budget_effective_days) * share / 100
      end
    end
    @crevenues = [{
        name: self.name,
        sum_budget: sum_budget,
        sum_period_budget: sum_period_budget,
        split_budget: split_budget,
        split_period_budget: split_period_budget
    }]
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
    @all_activities = []
    @all_activities += activities

    members = teams_tree_members

    Deal.joins(:deal_members).includes(:activities).where(:deal_members => { :user_id => members }).each do |as|
      as.activities.each do |a|
        @all_activities += [a] if !@all_activities.include?(a)
      end
    end
    Client.joins(:client_members).includes(:activities).where(:client_members => { :user_id => members }).each do |as|
      as.activities.each do |a|
        @all_activities += [a] if !@all_activities.include?(a)
      end
    end

    return @all_activities
  end
end
