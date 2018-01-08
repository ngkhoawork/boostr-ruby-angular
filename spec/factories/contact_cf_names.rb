FactoryBot.define do
  factory :contact_cf_name do
    company

    before(:create) do |item|
      if item.field_type.blank?
        item.field_type = %w(currency text note datetime number
                        number_4_dec integer boolean percentage
                        dropdown).sample
      end
    end

    after(:create) do |item|
      create(:contact_cf_option, contact_cf_name: item)
    end
  end
end
