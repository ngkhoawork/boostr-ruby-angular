class Hoopla::Actions::SyncCompaniesUsers
  def self.perform
    HooplaConfiguration.switched_on.each do |configuration|
      Hoopla::Actions::SyncCompanyUsers.new(company_id: configuration.company_id).perform
    end
  end
end
