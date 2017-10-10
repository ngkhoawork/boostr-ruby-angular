class ConnectDealClients < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      company.deals.find_each do |deal|
        if deal.agency.present? && deal.advertiser.present?
          deal.advertiser.agencies << deal.agency
          deal.agency.advertisers << deal.advertiser
        end
      end
    end
  end
end
