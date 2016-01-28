class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :company
  belongs_to :team, -> (user) { where(company_id: user.company_id) }, counter_cache: :members_count
  has_many :client_members
  has_many :clients, -> (user) { where(company_id: user.company_id) }, through: :client_members
  has_many :revenues, -> (user) { where(company_id: user.company_id) }
  has_many :deal_members
  has_many :deals, -> (user) { where(company_id: user.company_id) }, through: :deal_members
  has_many :quotas, -> (user) { where(company_id: user.company_id) }
  has_many :teams, -> (user) { where(company_id: user.company_id) }, foreign_key: :leader_id
  has_many :snapshots, -> (user) { where(company_id: user.company_id) }

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

  def as_json(options = {})
    super(options.merge(methods: [:name, :leader?]))
  end

  def all_deals_for_time_period(start_date, end_date)
    deals.for_time_period(start_date, end_date)
  end
end
