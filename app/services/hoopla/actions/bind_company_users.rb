class Hoopla::Actions::BindCompanyUsers < Hoopla::Actions::Base
  def perform
    users.each do |user|
      hoopla_server_user = hoopla_server_users.detect { |hoopla_user| hoopla_user[:email] == user.email }
      next unless hoopla_server_user

      (user.hoopla_user || user.create_hoopla_user!).update!(href: hoopla_server_user[:href])
    end
  end

  private

  def users
    @users ||= User.active.where(company_id: @options[:company_id])
  end

  def hoopla_server_users
    @hoopla_server_users ||= api_caller.get_users(access_token: @options[:access_token]).body
  end
end
