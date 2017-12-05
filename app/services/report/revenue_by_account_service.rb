module Report
  class RevenueByAccountService < Report::BaseService
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
      @required_option_keys ||= %i(company_id start_date end_date).freeze
    end

    def optional_param_keys
      @optional_option_keys ||= %i(client_types category_ids client_region_ids client_segment_ids page per_page).freeze
    end

    def format_records(records)
      records.each do |record|
        record.month_revenues = format_record_month_revenues(record)
      end
    end

    def format_record_month_revenues(record)
      record.month_revenues.inject(initialize_empty_period_revenues) do |period_revenues, revenue|
        year_month_key = "#{revenue['year']}-#{revenue['month']}"

        period_revenues[year_month_key] = revenue['revenue']
        period_revenues
      end
    end

    def initialize_empty_period_revenues
      empty_period_revenues.clone
    end

    def empty_period_revenues
      @empty_period_revenues ||=
        (@params[:start_date]..@params[:end_date]).map do |a|
          a.strftime('%Y-%-m')
        end.uniq.inject({}) do |period, year_month|
          period[year_month] = 0
          period
        end
    end

    class ScopeBuilder < BaseScopeBuilder
      def perform
        preload_associations(
          paginate(
            aggregate_by_period_revenue(
              apply_filters
            )
          )
        )
      end

      private

      def apply_filters
        FactTables::AccountRevenues::Report::FilteredQuery.new(@options).perform
      end

      def aggregate_by_month_revenue(relation)
        relation
          .joins(:account_dimension, :time_dimension)
          .where('revenue_amount > 0')
          .group(
            'account_dimension_id,
             account_dimensions.name,
             account_dimensions.account_type,
             account_revenue_facts.category_id,
             account_dimensions.client_region_id,
             account_dimensions.client_segment_id,
             EXTRACT(YEAR FROM start_date),
             EXTRACT(MONTH FROM start_date)'
          )
          .select(
            'account_dimension_id,
             account_dimensions.name,
             account_dimensions.account_type AS client_type,
             account_revenue_facts.category_id,
             account_dimensions.client_region_id,
             account_dimensions.client_segment_id,
             EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
             EXTRACT(MONTH FROM start_date) AS month,
             SUM(revenue_amount) AS month_revenue'
          )
      end

      def aggregate_by_period_revenue(relation)
        AccountRevenueFact
          .select(
            'account_dimension_id,
             name,
             client_type,
             category_id,
             client_region_id,
             client_segment_id,
             json_agg(
               json_build_object(\'year\', year, \'month\', month, \'revenue\', month_revenue)
             ) AS month_revenues,
             SUM(month_revenue) AS total_revenue'
          )
          .from(
            aggregate_by_month_revenue(relation)
          )
          .group(
            'account_dimension_id,
             name,
             client_type,
             category_id,
             client_region_id,
             client_segment_id'
          )
          .order('name ASC')
      end

      def preload_associations(relation)
        relation.includes(:client_category, :client_region, :client_segment, client: { primary_user: :team })
      end
    end
  end
end
