class ContactCfOption < ActiveRecord::Base
  belongs_to :contact_cf_name

  scope :by_options, -> option_ids { where('id NOT IN (?)', option_ids) }
end
