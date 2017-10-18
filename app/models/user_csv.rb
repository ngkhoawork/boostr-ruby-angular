class UserCsv
  include ActiveModel::Validations

  attr_accessor :email, :name, :title, :team, :currency, :user_type, :status, :is_admin, :revenue_requests,
                :employee_id, :office, :company_id, :inviter

  attr_reader :user

  validates_presence_of :email, :name, :user_type, :status

  validates_inclusion_of :status, in: %w(active inactive)
  validates_inclusion_of :user_type, in: [DEFAULT, SELLER, SALES_MANAGER, ACCOUNT_MANAGER,
                                          MANAGER_ACCOUNT_MANAGER, ADMIN, EXEC, FAKE_USER]

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    unless invitation_sent?
      invited_user = invite_user
      invited_user.add_role('admin') if is_admin
      invited_user.update_attributes!(user_params)
    end
  end

  def invite_user
    User.invite!({email: email}, inviter)
  end

  def user
    @user ||= User.find_by(email: email)
  end

  def invitation_sent?
    return false unless user
    !!user.invitation_sent_at
  end

  def user_params
    {
        email: email,
        first_name: first_name,
        last_name: last_name,
        title: title,
        default_currency: currency,
        user_type: user_type,
        revenue_requests_access: revenue_requests,
        employee_id: employee_id,
        office: office,
        team: team_record,
        is_active: user_status,
        company_id: company_id
    }
  end

  def first_name
    name.split(' ')[0]
  end

  def last_name
    name.split(' ')[1]
  end

  def user_status
    status == 'active'
  end

  def add_admin_role
    user.add_role('admin') if is_admin
  end

  def team_record
    Team.find_or_initialize_by(name: team)
  end
end