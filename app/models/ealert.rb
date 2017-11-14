class Ealert < ActiveRecord::Base
  belongs_to :company
  has_many :ealert_custom_fields
  has_many :ealert_stages

  validates :delay, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :ealert_custom_fields
  accepts_nested_attributes_for :ealert_stages
end
