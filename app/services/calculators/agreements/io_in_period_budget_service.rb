module Calculators
  module Agreements
    class IoInPeriodBudgetService < BaseService
      def perform
        in_period_amount
      end

      private

      def in_period_amount
        @_in_period_amount ||= content_fee_sum + display_line_items_sum
      end

      def content_fee_sum
        content_fee_budgets.sum('content_fee_product_budgets.budget')
      end

      def display_line_items_sum
        display_line_item_budgets.sum('display_line_item_budgets.budget')
      end

      def agreement_ios
        @_agreement_ios ||= agreement.ios
      end

      def content_fee_budgets
        Io.joins(:content_fee_product_budgets)
            .where('content_fee_product_budgets.start_date <= :agreement_end_date
                    AND content_fee_product_budgets.end_date >= :agreement_start_date
                    AND ios.id = :id',
                   agreement_end_date: agreement_end_date,
                   agreement_start_date: agreement_start_date,
                   id: io_id)
      end

      def display_line_item_budgets
        Io.joins(:display_line_item_budgets)
            .where('display_line_item_budgets.start_date <= :agreement_end_date
                    AND display_line_item_budgets.end_date >= :agreement_start_date
                    AND ios.id = :id',
                   agreement_end_date: agreement_end_date,
                   agreement_start_date: agreement_start_date,
                   id: io_id)
      end
    end
  end
end