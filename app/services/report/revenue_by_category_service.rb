module Report
  class RevenueByCategoryService < Report::BaseService

    def initialize(params)
      super
      @params[:start_date] = @params[:start_date].to_date
      @params[:end_date] = @params[:end_date].to_date
    end

    private

    def required_param_keys
      @_required_option_keys ||= %i(company_id start_date end_date category_ids).freeze
    end

    def optional_param_keys
      @_optional_option_keys ||= %i(client_region_ids client_segment_ids).freeze
    end

    def grouping_keys
      @_grouping_keys ||= %i(category_id year).freeze
    end

    def aggregating_keys
      @_aggregating_keys ||= %i(revenues total_revenue).freeze
    end

    def sort_data(data)
      data.sort_by do |records|
        [records[0].category_id, -records[0].year]
      end
    end

    # TODO: maybe it's worth to push it out to a distinct builder class
    def build_report_entity_params(records)
      # Fulfill with grouping attributes (common for all records in a group)
      params = grouping_keys.inject([]) { |acc, key| acc << records[0].send(key) }

      # Fulfill with an array of 'sum_revenue_amount' for each month in a given date period
      sum_revenue_amounts = build_month_period_with_zero_amounts(records[0])
      records.each { |r| sum_revenue_amounts[r.month.to_i] = r.sum_revenue_amount }
      params << sum_revenue_amounts

      # Fulfill with a year revenue
      params << sum_revenue_amounts.values.sum
    end

    def build_month_period_with_zero_amounts(record)
      start_month = @params[:start_date].year == record.year ? @params[:start_date].month : INT_MONTHS[:first]
      end_month   = @params[:end_date].year   == record.year ? @params[:end_date].month   : INT_MONTHS[:last]

      (start_month..end_month).inject({}) { |month_period, month| month_period[month] = 0; month_period }
    end

    class ScopeBuilder
      def initialize(options)
        @options = options
      end

      def perform
        aggregate_query(filter_query)
      end

      private

      def filter_query
        FactTables::AccountRevenues::Report::FilteredQuery.new(@options).perform
      end

      def aggregate_query(relation)
        relation.group(group_condition).select(select_condition)
      end

      def group_condition
        'account_revenue_facts.category_id, EXTRACT(YEAR FROM start_date), EXTRACT(MONTH FROM start_date)'
      end

      def select_condition
        'account_revenue_facts.category_id,
         EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
         EXTRACT(MONTH FROM start_date) AS month,
         SUM(revenue_amount) AS sum_revenue_amount'
      end
    end
  end
end
