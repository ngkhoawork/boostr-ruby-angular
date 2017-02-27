class Integration < ActiveRecord::Base
  OPERATIVE = 'operative'

  validates :external_id, :external_type, presence: true

  belongs_to :integratable, polymorphic: true

  scope :operative, -> { find_by(external_type: OPERATIVE) }
end
