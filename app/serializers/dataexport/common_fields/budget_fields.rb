module Dataexport
  module CommonFields
    module BudgetFields
      def budget_usd
        object.budget.to_f
      end

      def budget
        object.budget_loc.to_f
      end
    end
  end
end
