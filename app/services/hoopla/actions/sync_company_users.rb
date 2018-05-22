class Hoopla::Actions::SyncCompanyUsers < Hoopla::Actions::Base
  def perform
    add_users_to_hoopla_server

    delete_users_from_hoopla_server

    ensure_keeping_href_locally
  end

  private

  def add_users_to_hoopla_server
    users
      .select { |user| user_emails_for_addition.include?(user[:email]) }
      .each do |user|
        response = api_caller.create_user(
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          access_token: @options[:access_token]
        )

        hoopla_server_users << response.body if response.success?
      end
  end

  def delete_users_from_hoopla_server
    hoopla_server_users
      .select { |user| user_emails_for_deletion.include?(user[:email]) }
      .each do |user|
        response = api_caller.delete_user(
          href: user[:href],
          access_token: @options[:access_token]
        )

        hoopla_server_users.delete(user) if response.success?
      end
  end

  def ensure_keeping_href_locally
    users.each do |user|
      hoopla_server_user = hoopla_server_users.detect { |hoopla_user| hoopla_user[:email] == user.email }
      next unless hoopla_server_user

      (user.hoopla_user || user.create_hoopla_user!).update!(href: hoopla_server_user[:href])
    end
  end

  def user_emails_for_addition
    user_emails - hoopla_server_user_emails
  end

  def user_emails_for_deletion
    hoopla_server_user_emails - user_emails
  end

  def users
    @users ||= User.where(company_id: @options[:company_id]).to_a
  end

  def user_emails
    @user_emails ||= users.map(&:email)
  end

  def hoopla_server_users
    @hoopla_server_users ||= api_caller.get_users(access_token: @options[:access_token]).body
  end

  def hoopla_server_user_emails
    @hoopla_server_user_emails ||= hoopla_server_users.map { |hoopla_user| hoopla_user[:email] }
  end
end
