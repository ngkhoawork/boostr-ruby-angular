module Calculators
  module Agreements
    class SpendSummaryService < BaseService
      def perform
        dates_arr.each_with_object([]) do |date, arr|
          arr << spend_summary_for_date(start_date: date, end_date: date.end_of_month)
        end
      end

      private

      def spend_summary_for_date(**params)
        calculated_revenue = calculated_revenue(params[:start_date], params[:end_date], agreement_id)
        calculated_pipeline = calculated_pipeline(params[:start_date], params[:end_date], agreement_id)
        pipeline = calculated_pipeline[:unweighted_pipeline].to_f
        revenue = calculated_revenue[:revenue_amount].to_f

        { date: params[:start_date].strftime('%b %Y'), pipeline: pipeline, revenue: revenue, total: revenue + pipeline }
      end

      def first_month
        spend_agreement.start_date.beginning_of_month
      end

      def dates_range
        first_month..end_month
      end

      def dates_arr
        dates_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
      end

      def end_month
        spend_agreement.end_date
      end

      def spend_agreement
        @sa ||= SpendAgreement.find agreement_id
      end

      def calculated_revenue(start_date, end_date, agreement_id)
        Calculators::Agreements::RevenueService.new(agreement_start_date: start_date,
                                                    agreement_end_date: end_date,
                                                    agreement_id: agreement_id).perform
      end

      def calculated_pipeline(start_date, end_date, agreement_id)
        Calculators::Agreements::PipelineService.new(agreement_start_date: start_date,
                                                     agreement_end_date: end_date,
                                                     agreement_id: agreement_id).perform
      end
    end
  end
end