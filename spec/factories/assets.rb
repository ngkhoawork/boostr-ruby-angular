FactoryBot.define do
  factory :asset do
    asset_file_name { FFaker::BaconIpsum.word }
    asset_file_size { FFaker::Address.building_number }
    asset_content_type { FFaker::BaconIpsum.word }
    original_file_name { FFaker::BaconIpsum.word }
  end
end
