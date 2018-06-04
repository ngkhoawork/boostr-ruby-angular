module Calculators
  module Agreements
    class ForecastToTargetService < BaseService
      def perform
        return 0 if target_amount.zero?
        (revenue_amount + weighted_pipeline / target_amount) * 100
      end
    end
  end
end