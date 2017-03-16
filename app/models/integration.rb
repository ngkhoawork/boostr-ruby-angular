class Integration < ActiveRecord::Base
  OPERATIVE = 'operative'
  OPERATIVE_DATAFEED = 'Operative Datafeed'

  validates :external_id, :external_type, presence: true

  belongs_to :integratable, polymorphic: true

  scope :operative, -> { find_by(external_type: OPERATIVE) }
end
