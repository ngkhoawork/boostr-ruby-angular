class AccountCfName < ActiveRecord::Base
  belongs_to :company
  has_many :account_cf_options, dependent: :destroy

  accepts_nested_attributes_for :account_cf_options

  scope :by_type, -> type { where(field_type: type) if type.present? }
  scope :by_index, -> field_index { where(field_index: field_index) if field_index.present? }

  after_create do
    field_name = self.field_type + self.field_index.to_s
    self.company.account_cfs.update_all(field_name => nil)
  end

  def self.get_field_limit(type)
    puts "====="
    puts type
    field_limits = {
            "currency" => 7,
            "text" => 5,
            "note" => 2,
            "datetime" => 7,
            "number" => 7,
            "number_4_dec" => 7,
            "integer" => 7,
            "boolean" => 3,
            "percentage" => 5,
            "dropdown" => 7
    }
    field_limits[type]
  end
end
