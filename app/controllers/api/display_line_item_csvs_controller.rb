class Api::DisplayLineItemCsvsController < ApplicationController
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

      display_line_item = DisplayLineItemCsv.new(
        external_io_number: row[:sales_order_id],
        line_number: row[:sales_order_line_item_id],
        ad_server: 'O1',
        start_date: row[:sales_order_line_item_start_date],
        end_date: row[:sales_order_line_item_end_date],
        product_name: row[:product_name],
        quantity: row[:quantity],
        price: row[:net_unit_cost],
        pricing_type: row[:cost_type],
        budget: row[:net_cost],
        budget_delivered: row[:recognized_revenue],
        quantity_delivered: row[:cumulative_primary_performance],
        quantity_delivered_3p: row[:cumulative_third_party_performance],
        company_id: current_user.company.id
      )
      if display_line_item.valid?
        display_line_item.perform
      else
        error = { row: row_number, message: display_line_item.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end
end
