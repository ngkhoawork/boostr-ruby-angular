class AdvertiserAgencyRevenueFact < ActiveRecord::Base
  belongs_to :time_dimension
  belongs_to :advertiser, class_name: 'AccountDimension', foreign_key: :advertiser_id
  belongs_to :agency, class_name: 'AccountDimension', foreign_key: :agency_id
  belongs_to :company
end
