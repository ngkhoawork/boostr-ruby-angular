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
