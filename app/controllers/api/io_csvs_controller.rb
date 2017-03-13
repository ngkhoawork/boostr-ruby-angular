class Api::IoCsvsController < ApplicationController
  respond_to :json

  def create
    if params[:file].present?
      require 'timeout'
      begin
        @csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end

  private
  attr_reader :csv_file

  def errors
    errors = []
    row_number = 0

    CSV.parse(csv_file, { headers: true, header_converters: :symbol }) do |row|
      row_number += 1

      sales_order = IoCsv.new(
        io_external_number: row[:sales_order_id],
        io_name: row[:sales_order_name],
        io_start_date: row[:order_start_date],
        io_end_date: row[:order_end_date],
        io_advertiser: row[:advertiser_name],
        io_agency: row[:agency_name],
        io_budget: row[:total_order_value],
        io_budget_loc: row[:total_order_value],
        io_curr_cd: row[:order_currency_id],
        company_id: current_user.company.id
      )
      if sales_order.valid?
        sales_order.perform
      else
        error = { row: row_number, message: sales_order.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end
end
