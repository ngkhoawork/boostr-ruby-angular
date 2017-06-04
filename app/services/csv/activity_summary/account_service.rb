module Csv
  class ActivitySummary::AccountService < ActivitySummary::BaseService
    private

    def decorated_records
      records.map { |record| Csv::ActivitySummary::AccountDecorator.new(record, options) }
    end
  end
end
