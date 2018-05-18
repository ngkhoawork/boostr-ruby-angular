class Hoopla::Actions::SyncCompaniesUsers
  def self.perform
    HooplaConfiguration.switched_on.each do |configuration|
      Hoopla::Actions::SyncCompanyUsers.new(
        company_id: configuration.company_id,
        client_id: configuration.client_id,
        client_secret: configuration.client_secret
      ).perform
    end
  end
end
