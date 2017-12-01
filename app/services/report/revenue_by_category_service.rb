module Report
  class RevenueByCategoryService < Report::BaseService
    INT_MONTHS = { first: 1, last: 12 }.freeze

    def initialize(params)
      super
      @params[:start_date] = @params[:start_date].to_date
      @params[:end_date] = @params[:end_date].to_date
    end

    def perform
      format_records(super)
    end

    private

    def required_param_keys
      @_required_option_keys ||= %i(company_id start_date end_date category_ids).freeze
    end

    def optional_param_keys
      @_optional_option_keys ||= %i(client_region_ids client_segment_ids).freeze
    end

    def format_records(records)
      records.each do |record|
        record.month_revenues = format_record_month_revenues(record)
      end
    end

    def format_record_month_revenues(record)
      record.month_revenues.inject(initialize_empty_period_revenues(record)) do |period_revenues, revenue|
        period_revenues[revenue['month']] = revenue['revenue']
        period_revenues
      end
    end

    def initialize_empty_period_revenues(record)
      (record_start_month(record)..record_end_month(record)).inject({}) do |month_period, month|
        month_period[month] = 0
        month_period
      end
    end

    def record_start_month(record)
      @params[:start_date].year == record.year ? @params[:start_date].month : INT_MONTHS[:first]
    end

    def record_end_month(record)
      @params[:end_date].year == record.year ? @params[:end_date].month : INT_MONTHS[:last]
    end

    class ScopeBuilder
      def initialize(options)
        @options = options
      end

      def perform
        preload_associations(
          aggregate_by_period_revenue(
            apply_filters
          )
        )
      end

      private

      def apply_filters
        FactTables::AccountRevenues::Report::FilteredQuery.new(@options).perform
      end

      def aggregate_by_month_revenue(relation)
        relation
          .group(
            'account_revenue_facts.category_id,
             EXTRACT(YEAR FROM start_date),
             EXTRACT(MONTH FROM start_date)'
          )
          .select(
            'account_revenue_facts.category_id,
             EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
             EXTRACT(MONTH FROM start_date) AS month,
             SUM(revenue_amount) AS month_revenue'
          )
      end

      def aggregate_by_period_revenue(relation)
        AccountRevenueFact
          .select(
            'category_id,
             year,
             json_agg(
               json_build_object(\'month\', month, \'revenue\', month_revenue)
             ) AS month_revenues,
             SUM(month_revenue) AS total_revenue'
          )
          .from(
            aggregate_by_month_revenue(relation)
          )
          .group(
            'category_id,
             year'
          )
          .order('category_id ASC, year DESC')
      end

      def preload_associations(relation)
        relation.includes(:client_category)
      end
    end
  end
end
