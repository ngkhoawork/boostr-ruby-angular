require 'factory_girl'

namespace :create_io_api_seeds do
  desc "Create IO API seeds"
  task process_task: :environment do
    FactoryGirl.create_list(
      :csv_import_log,
      5,
      {
        company_id: 11,
        rows_processed: 1,
        rows_failed: 0,
        rows_imported: 1,
        object_name: 'display_line_item',
        source: 'api',
        created_at: (DateTime.now - 1.hour)
      }
    )

    FactoryGirl.create_list(
      :csv_import_log,
      5,
      {
        company_id: 11,
        rows_processed: 1,
        rows_failed: 0,
        rows_imported: 1,
        object_name: 'display_line_item',
        source: 'api',
        created_at: (DateTime.now - 24.hours)
      }
    )

    FactoryGirl.create_list(
      :csv_import_log,
      5,
      {
        company_id: 11,
        rows_processed: 1,
        rows_failed: 1,
        rows_imported: 0,
        error_messages: [{
          row: 1,
          message: ["Budget can't be blank",
          "Budget is not a number"]
        }],
        object_name: 'display_line_item',
        source: 'api',
        created_at: (DateTime.now - 1.hour)
      }
    )

    FactoryGirl.create_list(
      :csv_import_log,
      5,
      {
        company_id: 11,
        rows_processed: 1,
        rows_failed: 1,
        rows_imported: 0,
        error_messages: [{
          row: 1,
          message: ["Budget can't be blank",
          "Budget is not a number"]
        }],
        object_name: 'display_line_item',
        source: 'api',
        created_at: (DateTime.now - 24.hours)
      }
    )
  end
end
