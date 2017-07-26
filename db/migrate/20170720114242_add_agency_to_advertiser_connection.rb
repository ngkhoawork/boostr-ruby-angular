class AddAgencyToAdvertiserConnection < ActiveRecord::Migration
  def change
    ClientConnection.delete_all

    Company.find_each do |company|
      company.deals.find_each do |deal|
        if deal.agency.present? && deal.advertiser.present?
          unless ClientConnection.find_by(agency_id: deal.agency.id, advertiser_id: deal.advertiser.id).present?
            ClientConnection.create(agency_id: deal.agency.id, advertiser_id: deal.advertiser.id)
          end
        end
      end
    end
  end
end
