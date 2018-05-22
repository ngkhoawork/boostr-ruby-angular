class Hoopla::Actions::SyncCompanyUsers < Hoopla::Actions::Base
  def perform
    users
      .where(email: user_emails_for_addition)
      .each do |user|
        response = api_caller.create_user(
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          access_token: @options[:access_token]
        )

        update_user_href_locally!(user, response)
      end
  end

  private

  def update_user_href_locally!(user, response)
    if response.success?
      (user.hoopla_user || user.create_hoopla_user!).update!(href: response[:href])
    else
      raise Hoopla::Errors::UnhandledRequest, response.body
    end
  end

  def user_emails_for_addition
    users.where('created_at > ?', 24.hours.ago).pluck(:email) - hoopla_server_user_emails
  end

  def hoopla_server_user_emails
    @hoopla_server_user_emails ||= hoopla_server_users.map { |hoopla_user| hoopla_user[:email] }
  end

  def users
    @users ||= User.active.where(company_id: @options[:company_id])
  end

  def hoopla_server_users
    @hoopla_server_users ||= api_caller.get_users(access_token: @options[:access_token]).body
  end
end
