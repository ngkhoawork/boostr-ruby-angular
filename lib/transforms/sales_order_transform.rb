class Transforms::SalesOrderTransform
  def initialize(source, options = { headers: true, header_converters: :symbol })
    @source = source
    @options = options
  end

  def transform
    parse_and_process_rows
  end

  private
  attr_reader :source, :options

  # TODO LIMIT IO SEARCHES TO ONE COMPANY
  def parse_and_process_rows
    CSV.parse(source, options) do |row|
      #find
      io = Io.find_by_external_io_number row[:sales_order_id]

      if io.nil? && row[:sales_order_name] && row[:sales_order_name].split('_').count > 1 && io_number(row[:sales_order_name])
        io = Io.find_by_io_number io_number(row[:sales_order_name])
      end

      if io
        if io.content_fees.count == 0 && row[:order_start_date] && order_start_date(row[:order_start_date]) < io.start_date
          io.start_date = row[:order_start_date]
        end

        if io.content_fees.count == 0 && row[:order_end_date] && order_end_date(row[:order_end_date]) < io.end_date
          io.end_date = row[:order_end_date]
        end

        io.external_io_number = row[:sales_order_id]
        io.save
      else
        # TODO ADD MULTYCURRENCY CONVERSIONS AND CHECKS
        # TODO ADD COMPANY_ID PARAM
        # company_id: company_id,
        temp_io_params = {
          external_io_number: row[:sales_order_id].to_i,
          name: row[:sales_order_name],
          start_date: row[:order_start_date],
          end_date: row[:order_end_date],
          advertiser: row[:advertiser_name],
          agency: row[:agency_name],
          budget: row[:total_order_value],
          budget_loc: row[:total_order_value],
          curr_cd: row[:order_currency_id]
        }

        temp_io = TempIo.find_by_external_io_number row[:sales_order_id]
        temp_io ||= TempIo.new

        temp_io.update(
          temp_io_params
        )
      end
    end
  end

  def io_name(value)
    value.split('_')[0..-2].join('_')
  end

  def io_number(value)
    value.try(:split, '_').try(:last)
  end

  def order_start_date(value)
    Date.parse(value) rescue nil
  end

  def order_end_date(value)
    Date.parse(value) rescue nil
  end
end
