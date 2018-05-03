class PublisherCustomFieldOption < ActiveRecord::Base
  belongs_to :publisher_custom_field_name

  scope :by_options, -> option_ids { where('id NOT IN (?)', option_ids) }
end
