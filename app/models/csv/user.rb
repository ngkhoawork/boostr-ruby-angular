class Csv::User
  include ActiveModel::Validations

  attr_accessor :email, :name, :title, :team, :user_type, :currency, :status, :is_admin, :revenue_requests,
                :employee_id, :office, :company_id, :inviter

  attr_reader :user

  validates_presence_of :email, :name, :user_type, :status
  validates_inclusion_of :status, in: %w(active inactive)

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    self.user_type = user_type&.downcase
    self.status = status&.downcase
    self.is_admin = is_admin.to_s.downcase == 'true' ? true :false
  end

  def perform
    return update_attributes_for!(user) if !!invitation_sent? && user
    invited_user = invite_user
    update_attributes_for!(invited_user)
  end

  def update_attributes_for!(user)
    user.add_role('admin') if is_admin
    user.update_attributes!(user_params)
  end

  def invite_user
    User.invite!({email: email}, inviter)
  end

  def user
    @user ||= User.find_by(email: email)
  end

  def invitation_sent?
    !!user && !!user.invitation_sent_at
  end

  def user_params
    {
        email: email,
        first_name: first_name,
        last_name: last_name,
        title: title,
        default_currency: currency,
        user_type: integer_user_type,
        revenue_requests_access: revenue_requests,
        employee_id: employee_id,
        office: office,
        team: team_record,
        is_active: user_status,
        company_id: company_id
    }
  end

  def integer_user_type
    case user_type
      when 'default'
        DEFAULT
      when 'seller'
        SELLER
      when 'sales manager'
        SALES_MANAGER
      when 'account manager'
        ACCOUNT_MANAGER
      when 'manager account manager'
        MANAGER_ACCOUNT_MANAGER
      when 'admin'
        ADMIN
      when 'exec'
        EXEC
      when 'fake user'
        FAKE_USER
      else
        DEFAULT
    end
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