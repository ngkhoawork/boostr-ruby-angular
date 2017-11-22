class ClientConnection < ActiveRecord::Base
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'

  validates :agency_id, uniqueness: { scope: :advertiser_id, message: 'has already been taken for a given advertiser_id' }

  def as_json(options)
    super(options.merge(include: {
                                advertiser: {
                                        include: [:address]
                                },
                                agency: {
                                        include: [:address]
                                }
                        }))
  end
end
