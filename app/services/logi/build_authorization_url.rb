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
    if Rails.env.development? || Rails.env.jorzh?
      'BoostrQA'
    else
      'BoostrAnalytics'
    end
  end

  def url_request_params
    request_params.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  def request_params
    {
      Username: @user.name,
      Rights: define_user_rights,
      companyID: @company_id.to_s,
      userID: @user.id,
      userEMAIL: @user.email
    }
  end

  def define_user_rights
    @user.is?(:superadmin) ? 'SuperAdmin' : ''
  end

end