class AccountRevenueFact < ActiveRecord::Base
  belongs_to :company
  belongs_to :account_dimension
  belongs_to :client, foreign_key: :account_dimension_id
  belongs_to :time_dimension
  belongs_to :client_category, class_name: 'Option', foreign_key: 'category_id'
  belongs_to :client_region, class_name: 'Option'
  belongs_to :client_segment, class_name: 'Option'

  # Create delegate methods:
  #   client_category_name, client_region_name, client_segment_name
  %i(client_category client_region client_segment).each do |option_assoc|
    define_method("#{option_assoc}_name") do
      send(option_assoc)&.name
    end
  end
end
