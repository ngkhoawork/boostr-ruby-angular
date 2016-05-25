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
  has_many :deals, -> (user) { where(company_id: user.company_id) }, through: :deal_members
  has_many :quotas, -> (user) { where(company_id: user.company_id) }
  has_many :teams, -> (user) { where(company_id: user.company_id) }, foreign_key: :leader_id
  has_many :team_members, -> (user) { where(company_id: user.company_id) }, through: :teams, source: :members
  has_many :snapshots, -> (user) { where(company_id: user.company_id) }
  has_many :activities
  has_many :reports

  ROLES = %w(user admin superadmin)

  validates :first_name, :last_name, presence: true

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
    super(options.merge(
      include: {
        reports: {}
      },
      methods: [:name, :leader?, :leader]
    ))
  end

  def all_deals_for_time_period(start_date, end_date)
    deals.open.for_time_period(start_date, end_date)
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
