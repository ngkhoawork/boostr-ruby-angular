FactoryBot.define do
  factory :csv_import_log do
    rows_processed 1
rows_imported 1
rows_failed 1
error_messages "MyText"
file_source "MyString"
object_name "MyString"
  end

end
