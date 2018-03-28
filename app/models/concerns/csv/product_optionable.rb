module Csv
  module ProductOptionable
    extend ActiveSupport::Concern

    included do
      def product_full_name
        "#{product_name} #{product_level1} #{product_level2}".strip
      end
    end
  end
end
