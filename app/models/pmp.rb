class Pmp < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :company

  has_many :pmp_members, dependent: :destroy
  has_many :pmp_items, dependent: :destroy
end