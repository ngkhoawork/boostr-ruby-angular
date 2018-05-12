module HasCustomField
  extend ActiveSupport::Concern

  included do
    has_one :custom_field, as: :subject, dependent: :destroy, inverse_of: :subject

    accepts_nested_attributes_for :custom_field
  end
end
