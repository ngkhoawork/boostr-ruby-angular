class Deal < ActiveRecord::Base
  belongs_to :company
  belongs_to :advertiser, class_name: 'Client'
  belongs_to :agency, class_name: 'Client'

  validates :advertiser_id, presence: true

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :agency]))
  end
end
