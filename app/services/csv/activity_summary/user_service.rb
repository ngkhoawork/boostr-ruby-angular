module Csv
  class ActivitySummary::UserService < ActivitySummary::BaseService
    private

    def decorated_records
      records.map { |record| Csv::ActivitySummary::UserDecorator.new(record, options) }
    end
  end
end
