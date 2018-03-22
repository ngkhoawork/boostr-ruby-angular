class SspAdvertiser < ActiveRecord::Base
  belongs_to :ssp
  belongs_to :company
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by
  belongs_to :client

  validates :name, presence: true

  def self.create_or_update(name, client_id, ssp_id, user)
    ssp_advertiser = SspAdvertiser.find_or_initialize_by(
      name: name,
      ssp_id: ssp_id,
      company: user.company
    )
    ssp_advertiser.client_id = client_id
    ssp_advertiser.created_by ||= user
    ssp_advertiser.updated_by = user
    ssp_advertiser.save!    
  end
end