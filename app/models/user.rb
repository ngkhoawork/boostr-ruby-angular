class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :company

  has_many :client_members
  has_many :clients, through: :client_members
  has_many :revenues

  ROLES = %w(user superadmin)

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
    name = []
    name << first_name.chr + '.' if first_name
    name << last_name if last_name
    name.join(' ')
  end

  def as_json(options = {})
    super(options.merge(methods: [:name]))
  end
end
