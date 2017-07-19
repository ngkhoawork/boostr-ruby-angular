FactoryGirl.define do
  factory :asset_csv do
    original_file_name { FFaker::BaconIpsum.word }
    attachable_id nil
    attachable_type 'Deal'
    created_at { FFaker::Time.date }
    uploader_email nil

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
