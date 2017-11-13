class SalesStage < ActiveRecord::Base
  belongs_to :company
  belongs_to :sales_stageable, polymorphic: true

  validates :name, :probability, :position,  presence: true
end
