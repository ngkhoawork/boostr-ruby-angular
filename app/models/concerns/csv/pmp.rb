module Csv
  module Pmp
    extend ActiveSupport::Concern
    included do

      def raise_error(key)
        raise "#{key} does not exist"
      end

      def formatted_date(val)
        #csv auto-format '3/1/18'
        date = Date.strptime(val.gsub(/[-:]/, '/'), '%m/%d/%Y')
        date += 2000.years if date.year.to_s.length == 2
        date
      rescue
        raise 'Date format does not fit MM/DD/YYYY pattern'
      end

      def raise_invalid_field(key)
        raise "Invalid #{key} field"
      end

      def check_and_format_date(val)
        val.present? ? formatted_date(val) : formatted_date(Time.zone.now.to_date.strftime('%m/%d/%Y').to_s)
      end

    end
  end
end
