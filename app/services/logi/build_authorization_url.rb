class Logi::BuildAuthorizationUrl
  DOMAIN = 'https://analytics.boostr.com/'.freeze
  SECURE_KEY_PATH = '/rdTemplate/rdGetSecureKey.aspx'.freeze

  def initialize(user, company_id)
    @user = user
    @company_id = company_id
  end

  def params
    {
      request_param: '?' + request_params.map { |key, value| "#{key}=#{value}" }.join('&'),
      domain: DOMAIN,
      secure_key_url: SECURE_KEY_PATH,
      env: logi_env
    }
  end

  def logi_env
    if Rails.env.production?
      'BoostrAnalytics'
    else
      'BoostrQA'
    end
  end

  def url_request_params
    request_params.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  private

  def request_params
    {
      Username: @user.name,
      Rights: define_user_rights,
      companyID: @company_id.to_s,
      userID: @user.id,
      userEMAIL: @user.email,
      userType: define_user_type(@user.user_type)
    }
  end

  def define_user_rights
    @user.is?(:superadmin) || @user.is?(:supportadmin) ? 'SuperAdmin' : ''
  end

  def define_user_type type
    case type
      when DEFAULT
        'Default'
      when SELLER
        'Seller'
      when SALES_MANAGER
        'SalesManager'
      when ACCOUNT_MANAGER
        'AccountManager'
      when MANAGER_ACCOUNT_MANAGER
        'ManagerAccountManager'
      when ADMIN
        'Admin'
      when EXEC
        'Exec'
      when FAKE_USER
        'FakeUser'
      else
        'Default'
    end
  end
end