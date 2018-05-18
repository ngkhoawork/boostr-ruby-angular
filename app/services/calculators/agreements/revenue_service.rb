module Calculators
  module Agreements
    class RevenueService < BaseService
      def perform
        { revenue_amount: revenue_sum }
      end

      private

      def revenue_sum
        @_revenue_sum ||= content_fee_sum + display_line_items_sum
      end

      def content_fee_sum
        content_fee_budgets.sum('content_fee_product_budgets.budget')
      end

      def display_line_items_sum
        display_line_item_budgets.sum('display_line_item_budgets.budget')
      end

      def content_fee_budgets
        SpendAgreement
            .joins(ios: :content_fee_product_budgets)
            .where('content_fee_product_budgets.start_date <= :agreement_end_date
                    AND content_fee_product_budgets.end_date >= :agreement_start_date
                    AND spend_agreements.id = :agreement_id',
                   agreement_end_date: agreement_end_date,
                   agreement_start_date: agreement_start_date,
                   agreement_id: agreement_id)
      end

      def display_line_item_budgets
        SpendAgreement
            .joins(ios: :display_line_item_budgets)
            .where('display_line_item_budgets.start_date <= :agreement_end_date
                    AND display_line_item_budgets.end_date >= :agreement_start_date
                    AND spend_agreements.id = :agreement_id',
                   agreement_end_date: agreement_end_date,
                   agreement_start_date: agreement_start_date,
                   agreement_id: agreement_id)
      end
    end
  end
end