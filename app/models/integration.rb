class Integration < ActiveRecord::Base
  OPERATIVE = 'operative'

  belongs_to :integratable, polymorphic: true

  scope :operative, -> { find_by(external_type: OPERATIVE) }
end
