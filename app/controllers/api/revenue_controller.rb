class Api::RevenueController < ApplicationController
  respond_to :json, :csv

  def forecast_detail
    if valid_time_period?
      if params[:product_ids].present?
        render json: quarterly_product_ios
      else
        render json: quarterly_ios
      end
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def create
    csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

  def report_by_category
    respond_to do |format|
      format.json {
        render json: revenue_by_category_report,
               each_serializer: Report::RevenueByCategorySerializer
      }
      format.csv {
        send_data Csv::RevenueByCategoryService.new(revenue_by_category_report).perform,
                  filename: "reports-revenue_by_category-#{DateTime.current}.csv"
      }
    end
  end

  def report_by_account
    respond_to do |format|
      format.json {
        render json: revenue_by_account_report,
               each_serializer: Report::RevenueByAccountSerializer
      }
      format.csv {
        send_data Csv::RevenueByAccountService.new(revenue_by_account_report).perform,
                  filename: "reports-revenue_by_account-#{DateTime.current}.csv"
      }
    end
  end

  private

  def quarterly_ios
    if params[:team_id] == 'all' && params[:user_id] == 'all'
      all_users = current_user.company.users
      ios = current_user.company.ios
                    .for_time_period(start_date, end_date)
                    .as_json
      year = start_date.year
      ios.map do |io|
        io_obj = Io.find(io['id'])

        sum_period_budget, split_period_budget = 0, 0

        io_users = io_obj.users.pluck(:id)
        io_team_users = all_users.select do |user|
          io_users.include?(user.id)
        end

        io_team_users.each do |user|
          result = io_obj.for_forecast_page(start_date, end_date, user)
          sum_period_budget += result[0] if sum_period_budget == 0
          split_period_budget += result[1]
        end
        start_month = time_period.start_date.month
        end_month = time_period.end_date.month
        io[:quarters] = Array.new(4, nil)
        io[:months] = Array.new(12, nil)
        for i in start_month..end_month
          io[:months][i - 1] = 0
        end
        for i in ((start_month - 1) / 3)..((end_month - 1) / 3)
          io[:quarters][i] = 0
        end
        io[:members] = io_obj.io_members.as_json

        if io['end_date'] == io['start_date']
          io['end_date'] += 1.day
        end

        io_obj.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
          month = content_fee_product_budget.start_date.mon
          io[:months][month - 1] += content_fee_product_budget.budget
          io[:quarters][(month - 1) / 3] += content_fee_product_budget.budget
        end

        io_obj.display_line_items.for_time_period(start_date, end_date).each do |display_line_item|
          display_line_item_budgets = display_line_item.display_line_item_budgets.to_a

          for index in start_date.mon..end_date.mon
            month = index.to_s
            if index < 10
              month = '0' + index.to_s
            end
            first_date = Date.parse("#{year}#{month}01")

            num_of_days = [[first_date.end_of_month, display_line_item.end_date].min - [first_date, display_line_item.start_date].max + 1, 0].max.to_f
            in_budget_days = 0
            in_budget_total = 0
            display_line_item_budgets.each do |display_line_item_budget|
              in_from = [first_date, display_line_item.start_date, display_line_item_budget.start_date].max
              in_to = [first_date.end_of_month, display_line_item.end_date, display_line_item_budget.end_date].min
              in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
              in_budget_days += in_days
              in_budget_total += display_line_item_budget.daily_budget * in_days
            end
            budget = in_budget_total + display_line_item.ave_run_rate * (num_of_days - in_budget_days)
            io[:months][index - 1] += budget
            io[:quarters][(index - 1) / 3] += budget
          end
        end

        io['in_period_amt'] = sum_period_budget
        io['in_period_split_amt'] = split_period_budget
      end

      ios
    else
      member_or_team.quarterly_ios(time_period.start_date, time_period.end_date)
    end
  end

  def quarterly_product_ios
    if params[:team_id] == 'all' && params[:user_id] == 'all'
      data = []
      all_users = current_user.company.users
      # ios = all_users.map { |user| user.all_ios_for_time_period(start_date, end_date)  }.flatten.uniq.as_json
      ios = current_user.company.ios
                    .for_time_period(start_date, end_date)
                    .as_json
      year = start_date.year
      ios.each do |io|
        io_obj = Io.find(io['id'])

        io_users = io_obj.users.pluck(:id)
        io_team_users = all_users.select do |user|
          io_users.include?(user.id)
        end
        io[:members] = io_obj.io_members.as_json

        if io['end_date'] == io['start_date']
          io['end_date'] += 1.day
        end

        product_ios = {}

        content_fee_rows = io_obj.content_fees
        content_fee_rows = content_fee_rows.for_product_ids(product_ids) if product_ids.present?
        content_fee_rows.each do |content_fee|
          content_fee.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
            item_product_id = content_fee.product_id
            if product_ios[item_product_id].nil?
              product_ios[item_product_id] = JSON.parse(JSON.generate(io))
              product_ios[item_product_id][:product_id] = item_product_id
              product_ios[item_product_id][:product] = content_fee.product
            end
          end
        end

        display_line_item_rows = io_obj.display_line_items.for_time_period(start_date, end_date)
        display_line_item_rows = display_line_item_rows.for_product_ids(product_ids) if product_ids.present?
        display_line_item_rows.each do |display_line_item|
          item_product_id = display_line_item.product_id
          if product_ios[item_product_id].nil?
            product_ios[item_product_id] = JSON.parse(JSON.generate(io))
            product_ios[item_product_id][:product_id] = item_product_id
            product_ios[item_product_id][:product] = display_line_item.product
          end
        end

        product_ios.each do |index, item|
          sum_period_budget, split_period_budget = 0, 0
          io_team_users.each do |user|
            if item[:product]
              result = io_obj.for_product_forecast_page(item[:product], start_date, end_date, user)
              sum_period_budget += result[0] if sum_period_budget == 0
              split_period_budget += result[1]
            end
          end
          product_ios[index]['in_period_amt'] = sum_period_budget
          product_ios[index]['in_period_split_amt'] = split_period_budget
        end

        data = data + product_ios.values
      end

      data
    else
      member_or_team.quarterly_product_ios(product_ids, time_period.start_date, time_period.end_date)
    end
  end

  def time_period
    if params[:time_period_id].present?
      @time_period ||= current_user.company.time_periods.find_by_id(params[:time_period_id])
    elsif params['year'].present? && params['quarter'].present?
      @time_period ||= current_user.company.time_periods.find_by(start_date: quarters[quarter - 1][:start_date].to_date, end_date: quarter[quarter - 1][:end_date].to_date)
    end
  end

  def valid_time_period?
    if params[:time_period_id].present? && time_period.present?
      if time_period.start_date == time_period.start_date.beginning_of_year && time_period.end_date == time_period.start_date.end_of_year
        return true
      elsif time_period.start_date == time_period.start_date.beginning_of_quarter && time_period.end_date == time_period.start_date.end_of_quarter
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def year
    return nil if params[:year].blank?

    params[:year].to_i
  end

  def quarter
    return nil if params[:quarter].blank? || !params[:quarter].to_i.in?(1..4)

    params[:quarter].to_i
  end

  def quarters
    return @quarters if defined?(@quarters)

    @quarters = []
    @quarters << { start_date: Date.new(year, 1, 1), end_date: Date.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Date.new(year, 4, 1), end_date: Date.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Date.new(year, 7, 1), end_date: Date.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Date.new(year, 10, 1), end_date: Date.new(year, 12, 31), quarter: 4 }
    @quarters = @quarters.map do |quarter|
      quarter[:range] = quarter[:start_date] .. quarter[:end_date]
      quarter
    end
    @quarters
  end

  def start_date
    if year && quarter
      quarters[quarter-1][:start_date]
    else
      time_period.start_date
    end
  end

  def end_date
    if year && quarter
      quarters[quarter-1][:end_date]
    else
      time_period.end_date
    end
  end

  def product_ids
    @product_ids ||= if params[:product_ids].present? && params[:product_ids] != ['all']
      params[:product_ids]
    elsif product_family
      product_family.products.collect(&:id)
    else
      nil
    end
  end

  def product_family
    @_product_family ||= if params[:product_family_id] && params[:product_family_id] != 'all'
      company.product_families.find_by(id: params[:product_family_id])
    else
      nil
    end
  end

  def product
    @product ||= if params[:product_id].present? && params[:product_id] != ['all']
      Product.find_by(id: params[:product_id])
    else
      nil
    end
  end

  def member_or_team
    @member_or_team ||= if params[:user_id].present? && params[:user_id] != 'all'
      member
    elsif params[:member_id] && params[:member_id] != 'all'
      member
    elsif params[:team_id] && params[:team_id] != 'all'
      team
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def company
    @_company ||= current_user.company
  end

  def member
    @member ||= if params[:user_id]
      current_user.company.users.find(params[:user_id])
    elsif params[:member_id]
      current_user.company.users.find(params[:member_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def team
    @team ||= current_user.company.teams.find(params[:team_id])
  end

  def revenue_by_category_report
    Report::RevenueByCategoryService.new(revenue_by_category_report_params).perform
  end

  def revenue_by_account_report
    Report::RevenueByAccountService.new(revenue_by_account_report_params).perform
  end

  def revenue_by_category_report_params
    %i(start_date end_date category_ids).each { |param_name| params.require(param_name) }

    params.permit(:start_date, :end_date, client_region_ids: [], client_segment_ids: [], category_ids: [])
          .merge!(company_id: current_user.company_id)
  end

  def revenue_by_account_report_params
    %i(start_date end_date).each { |param_name| params.require(param_name) }

    params
      .permit(
        :client_types,
        :start_date,
        :end_date,
        :page,
        :per_page,
        category_ids: [],
        client_region_ids: [],
        client_segment_ids: []
      ).merge!(company_id: current_user.company_id)
  end
end
