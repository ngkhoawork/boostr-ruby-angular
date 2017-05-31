class Ealert < ActiveRecord::Base
  belongs_to :company
  has_many :ealert_custom_fields
  has_many :ealert_stages

  accepts_nested_attributes_for :ealert_custom_fields
  accepts_nested_attributes_for :ealert_stages
end
