module Calculators
  module Agreements
    class BookedToTargetService < BaseService
      def perform
        return 0 if target_amount.zero?
        revenue_amount / target_amount * 100
      end
    end
  end
end