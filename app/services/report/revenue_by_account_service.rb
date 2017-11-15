module Report
  class RevenueByAccountService < Report::BaseService
    def initialize(params)
      super
      @params[:start_date] = @params[:start_date].to_date
      @params[:end_date] = @params[:end_date].to_date
    end

    private

    def required_param_keys
      @_required_option_keys ||= %i(company_id start_date end_date).freeze
    end

    def optional_param_keys
      @_optional_option_keys ||= %i(client_types category_ids client_region_ids client_segment_ids).freeze
    end

    def grouping_keys
      @_grouping_keys ||= %i(name category_id client_region_id client_segment_id team_name seller_names).freeze
    end

    def aggregating_keys
      @_aggregating_keys ||= %i(revenues total_revenue).freeze
    end

    def sort_data(data)
      data.sort_by do |records|
        [records[0].name, records[0].team_name.to_s, records[0].seller_names.to_s]
      end
    end

    def build_report_entity_params(records)
      # Fulfill with grouping attributes (common for all records in a group)
      params = grouping_keys.inject([]) { |acc, key| acc << records[0].send(key) }

      sum_revenue_amounts = build_month_period_with_zero_amounts
      records.each { |r| sum_revenue_amounts["#{r.year}-#{r.month.to_i}"] = r.sum_revenue_amount }
      params << sum_revenue_amounts

      # Fulfill with a full period revenue
      params << sum_revenue_amounts.values.sum
    end

    def build_month_period_with_zero_amounts
      (@params[:start_date]..@params[:end_date]).map do |a|
        a.strftime('%Y-%-m')
      end.uniq.inject({}) do |period, year_month|
        period[year_month] = 0
        period
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
        relation
          .joins(:account_dimension, :time_dimension)
          .group(group_condition)
          .select(select_condition)
      end

      def group_condition
        'account_dimensions.name,
         account_revenue_facts.category_id,
         client_region_id,
         client_segment_id,
         team_name,
         seller_names,
         EXTRACT(YEAR FROM start_date),
         EXTRACT(MONTH FROM start_date)'
      end

      def select_condition
        'account_dimensions.name,
         account_revenue_facts.category_id,
         account_revenue_facts.client_region_id,
         account_revenue_facts.client_segment_id,
         team_name,
         seller_names,
         EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
         EXTRACT(MONTH FROM start_date) AS month,
         SUM(revenue_amount) AS sum_revenue_amount'
      end
    end
  end
end
