class Api::DealsController < ApplicationController
  respond_to :json, :zip

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
          render json: suggest_deals
        elsif params[:activity].present?
          render json: activity_deals
        elsif params[:time_period_id].present?
          if valid_time_period?
            render json: forecast_deals
          else
            render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
          end
        elsif params[:year].present?
          response_deals = company.deals
            .includes(
              :deal_members,
              :advertiser,
              :agency,
              :stage,
              :creator,
              :values,
              :deal_custom_field
            )
            .where("date_part('year', start_date) <= ? AND date_part('year', end_date) >= ?", params[:year], params[:year])
            .less_than(100)
            .as_json

          response_deals = response_deals.map do |deal|
            range = deal['start_date'] .. deal['end_date']

            deal['month_amounts'] = []
            monthly_revenues = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id").select("date_part('month', start_date) as month, sum(deal_product_budgets.budget) as revenue").where("deal_products.deal_id=? and date_part('year', start_date) = ?", deal['id'], params[:year]).group("date_part('month', start_date)").order("date_part('month', start_date) asc").collect {|deal| {month: deal.month.to_i, revenue: deal.revenue.to_i}}

            index = 0
            monthly_revenues.each do |monthly_revenue|
              for i in index..(monthly_revenue[:month]-2)
                deal['month_amounts'].push 0
              end
              deal['month_amounts'].push monthly_revenue[:revenue]
              index = monthly_revenue[:month]
            end
            for i in index..11
              deal['month_amounts'].push 0
            end

            deal['months'] = []
            month = Date.parse("#{year-1}1201")
            while month = month.next_month and month.year == year do
              month_range = month.at_beginning_of_month..month.at_end_of_month
              if month_range.overlaps? range
                overlap = [deal['start_date'], month_range.begin].max..[deal['end_date'], month_range.end].min
                deal['months'].push((overlap.end.to_time - overlap.begin.to_time) / (deal['end_date'].to_time - deal['start_date'].to_time))
                deal
              else
                deal['months'].push 0
              end
            end

            deal['quarter_amounts'] = []
            quarterly_revenues = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id").select("date_part('quarter', start_date) as quarter, sum(deal_product_budgets.budget) as revenue").where("deal_id=? and date_part('year', start_date) = ?", deal['id'], params[:year]).group("date_part('quarter', start_date)").order("date_part('quarter', start_date) asc").collect {|deal| {quarter: deal.quarter.to_i, revenue: deal.revenue.to_i}}
            index = 0
            quarterly_revenues.each do |quarterly_revenue|
              for i in index..(quarterly_revenue[:quarter]-2)
                deal['quarter_amounts'].push 0
              end
              deal['quarter_amounts'].push quarterly_revenue[:revenue]
              index = quarterly_revenue[:quarter]
            end
            for i in index..3
              deal['quarter_amounts'].push 0
            end

            deal['quarters'] = []
            quarters.each do |quarter|
              if quarter[:range].overlaps? range
                overlap = [deal['start_date'], quarter[:start_date]].max..[deal['end_date'], quarter[:end_date]].min
                deal['quarters'].push((overlap.end.to_time - overlap.begin.to_time) / (deal['end_date'].to_time - deal['start_date'].to_time))
                deal
              else
                deal['quarters'].push 0
              end
            end
            deal
          end
          render json: response_deals
        else
          render json: ActiveModel::ArraySerializer.new(deals.for_client(params[:client_id]).includes(:advertiser, :stage, :previous_stage, :deal_custom_field, :users, :currency).distinct , each_serializer: DealIndexSerializer).to_json
        end
      }
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            # Something that should be interrupted if it takes too much time...
            if current_user.leader?
              deals = company.deals
            elsif team.present?
              deals = team.deals
            else
              deals = current_user.deals
            end
            # send_data deals.to_csv, filename: "deals-#{Date.today}.csv"
            send_data Deal.to_csv(deals, company), filename: "deals-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def pipeline_report
    respond_to do |format|
      selected_deals = nil
      case params[:status]
        when 'open'
          selected_deals = deals.open.less_than(100)
        when 'all'
          selected_deals = deals
        when 'closed'
          selected_deals = deals.close_status
        else
          selected_deals = deals.open.less_than(100)
      end

      filtered_deals = selected_deals
      .by_values(deal_type_source_params)
      .includes(
        :advertiser,
        :latest_happened_activity,
        :stageinfo,
        :deal_product_budgets,
        :deal_custom_field,
        agency: [:parent_client],
        deal_members: [:username],
        values: [:option]
      )
      .active
      .distinct

      if time_period
        filtered_deals = filtered_deals.for_time_period(time_period.start_date, time_period.end_date)
      end

      # Filter by product id
      if product_filter
        filtered_deals = filtered_deals.joins('LEFT JOIN deal_products on deal_products.deal_id = deals.id').where(deal_products: { product_id: product_filter })
      end

      filtered_deals = filtered_deals.select do |deal|
        (deal_type_filter ? deal.values.map(&:option_id).include?(deal_type_filter) : true) &&
        (deal_source_filter ? deal.values.map(&:option_id).include?(deal_source_filter) : true)
      end

      format.json {
        deal_settings_fields = company.fields.where(subject_type: 'Deal').pluck(:id, :name)
        deal_list = ActiveModel::ArraySerializer.new(
          filtered_deals,
          each_serializer: DealReportSerializer,
          deal_settings_fields: deal_settings_fields,
          product_filter: product_filter
        )
        deal_ids = filtered_deals.collect{|deal| deal.id}

        range = DealProductBudget
        .joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
        .select("distinct(start_date)")
        .where("deal_products.deal_id in (?)", deal_ids)
        .order("start_date asc")
        .collect{|deal_product_budget| deal_product_budget.start_date.try(:beginning_of_month)}
        .compact
        .uniq

        render json: [{deals: deal_list, range: range}].to_json
      }
      format.csv {
        require 'timeout'
        begin
          Timeout::timeout(240) {
            send_data Deal.to_pipeline_report_csv(filtered_deals, company, product_filter), filename: "pipeline-report-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def pipeline_summary_report
    respond_to do |format|
      format.json {
        deal_list = ActiveModel::ArraySerializer.new(deals.includes(:advertiser, :agency, :stage, :previous_stage, :users, :deal_product_budgets, :deal_custom_field).distinct , each_serializer: DealReportSerializer)

        deal_ids = deals.open.collect{|deal| deal.id}
        range = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id").select("distinct(start_date)").where("deal_products.deal_id in (?)", deal_ids).order("start_date asc").collect{|deal_product_budget| deal_product_budget.start_date}
        render json: [{deals: deal_list, range: range}].to_json
      }
      format.csv {
        require 'timeout'
        begin
          Timeout::timeout(90) {
            send_data Deal.to_pipeline_summary_report_csv(company), filename: "pipeline-summary-report-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def show
    deal
  end

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = Deal.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    else
      @deal = company.deals.new(deal_params)

      deal.created_by = current_user.id
      deal.updated_by = current_user.id
      # deal.set_user_currency
      if deal.save
        render json: deal, status: :created
      else
        render json: { errors: deal.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    deal.updated_by = current_user.id
    if deal.update_attributes(deal_params)
      render deal
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal.destroy

    render nothing: true
  end

  def send_to_operative
    if deal.operative_switched_on?
      OperativeIntegrationWorker.perform_async(deal.id)
      render json: { message: 'deal was sent to operative' }
    else
      render json: { errors: 'cannot send this deal to operative please recheck a deal and try again later' },
             status: :unprocessable_entity
    end
  end

  private

  def forecast_deals
    response_deals = []
    if params[:user_id].present? && params[:user_id] != 'all'
      response_deals = user.deals
    elsif params[:team_id].present? && params[:team_id] == 'all'
      response_deals = company.deals
    else
      response_deals = all_team_deals
    end
    response_deals = response_deals
     .for_time_period(time_period.start_date, time_period.end_date)
     .open_partial
     .as_json({override: true, options: {
                      only: [
                              :id,
                              :name,
                              :stage_id,
                              :budget,
                              :budget_loc,
                              :curr_cd,
                              :next_steps,
                              :open,
                              :start_date,
                              :end_date
                      ],
                      include: {

                              stage: {
                                      only: [:id, :probability, :open, :active]
                              },
                              deal_members: {
                                      only: [:id, :share, :user_id],
                                      methods: [:name]
                              },
                              advertiser: {
                                      only: [:id, :name]
                              },
                              agency: {
                                      only: [:id, :name]
                              }
                      }
              }}
     )

    year = time_period.start_date.year

    response_deals = response_deals.map do |deal|
      range = deal['start_date'] .. deal['end_date']

      deal['month_amounts'] = []
      monthly_revenues = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
                                 .select("date_part('month', start_date) as month, sum(deal_product_budgets.budget) as revenue")
                                 .for_time_period(time_period.start_date, time_period.end_date)
                                 .where("deal_products.deal_id = ?", deal['id'])
                                 .group("date_part('month', start_date)").order("date_part('month', start_date) asc")
                                 .collect {|deal| {month: deal.month.to_i, revenue: deal.revenue.to_i}}

      index = 0
      monthly_revenues.each do |monthly_revenue|
        for i in index..(monthly_revenue[:month]-2)
          if i + 1 >= time_period.start_date.month && i + 1 <= time_period.end_date.month
            deal['month_amounts'].push 0
          else
            deal['month_amounts'].push nil
          end
        end
        if monthly_revenue[:month] >= time_period.start_date.month && monthly_revenue[:month] <= time_period.end_date.month
          deal['month_amounts'].push monthly_revenue[:revenue]
        end
        index = monthly_revenue[:month]
      end
      for i in index..11
        if i + 1 >= time_period.start_date.month && i + 1 <= time_period.end_date.month
          deal['month_amounts'].push 0
        else
          deal['month_amounts'].push nil
        end
      end

      deal['quarter_amounts'] = []
      quarterly_revenues = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
                                   .select("date_part('quarter', start_date) as quarter, sum(deal_product_budgets.budget) as revenue")
                                   .for_time_period(time_period.start_date, time_period.end_date)
                                   .where("deal_id = ?", deal['id'])
                                   .group("date_part('quarter', start_date)")
                                   .order("date_part('quarter', start_date) asc")
                                   .collect {|deal| {quarter: deal.quarter.to_i, revenue: deal.revenue.to_i}}
      index = 0
      quarterly_revenues.each do |quarterly_revenue|
        for i in index..(quarterly_revenue[:quarter]-2)
          if (i * 3 + 1) >= time_period.start_date.month && (i * 3 + 1) <= time_period.end_date.month
            deal['quarter_amounts'].push 0
          else
            deal['quarter_amounts'].push nil
          end
        end
        if ((quarterly_revenue[:quarter] - 1) * 3 + 1) >= time_period.start_date.month && ((quarterly_revenue[:quarter] - 1) * 3 + 1) <= time_period.end_date.month
          deal['quarter_amounts'].push quarterly_revenue[:revenue]
        end
        index = quarterly_revenue[:quarter]
      end
      for i in index..3
        if (i * 3 + 1) >= time_period.start_date.month && (i * 3 + 1) <= time_period.end_date.month
          deal['quarter_amounts'].push 0
        else
          deal['quarter_amounts'].push nil
        end
      end
      deal
    end

    response_deals
  end

  def product_filter
    if params[:product_id].presence && params[:product_id] != 'all'
      params[:product_id].to_i
    end
  end

  def deal_type_filter
    if params[:type].presence && params[:type] != 'all'
      params[:type].to_i
    end
  end

  def deal_source_filter
    if params[:source].presence && params[:source] != 'all'
      params[:source].to_i
    end
  end

  def deal_params
    params.require(:deal).permit(
        :name,
        :stage_id,
        :budget,
        :budget_loc,
        :curr_cd,
        :start_date,
        :end_date,
        :advertiser_id,
        :agency_id,
        :closed_at,
        :next_steps,
        :initiative_id,
        :closed_reason_text,
        {
            values_attributes: [
                :id,
                :field_id,
                :option_id,
                :value
            ],
            deal_custom_field_attributes: [
                :id,
                :company_id,
                :deal_id,
                :currency1,
                :currency2,
                :currency3,
                :currency4,
                :currency5,
                :currency6,
                :currency7,
                :currency_code1,
                :currency_code2,
                :currency_code3,
                :currency_code4,
                :currency_code5,
                :currency_code6,
                :currency_code7,
                :text1,
                :text2,
                :text3,
                :text4,
                :text5,
                :note1,
                :note2,
                :datetime1,
                :datetime2,
                :datetime3,
                :datetime4,
                :datetime5,
                :datetime6,
                :datetime7,
                :number1,
                :number2,
                :number3,
                :number4,
                :number5,
                :number6,
                :number7,
                :integer1,
                :integer2,
                :integer3,
                :integer4,
                :integer5,
                :integer6,
                :integer7,
                :boolean1,
                :boolean2,
                :boolean3,
                :percentage1,
                :percentage2,
                :percentage3,
                :percentage4,
                :percentage5,
                :dropdown1,
                :dropdown2,
                :dropdown3,
                :dropdown4,
                :dropdown5,
                :dropdown6,
                :dropdown7,
                :sum1,
                :sum2,
                :sum3,
                :sum4,
                :sum5,
                :sum6,
                :sum7,
                :number_4_dec1,
                :number_4_dec2,
                :number_4_dec3,
                :number_4_dec4,
                :number_4_dec5,
                :number_4_dec6,
                :number_4_dec7
            ]
        }
    )
  end

  def deal_type_source_params
    [params[:type], params[:source]].reject{|el| el.nil? || el == 'all'}
  end

  def user
    @user ||= company.users.find(params[:user_id])
  end

  def deal
    @deal ||= company.deals.find(params[:id])
  end

  def company
    @company ||= current_user.company
  end

  def deals
    if params[:filter] == 'company' && current_user.leader?
      company.deals.active
    elsif params[:filter] == 'selected_team' && params[:team_id]
      all_team_deals
    elsif params[:filter] == 'user' && params[:user_id]
      deal_member_filter
    elsif params[:filter] == 'team' && team.present?
      company.deals.by_deal_team(team.all_members.map(&:id) + team.all_leaders.map(&:id))
    elsif params[:client_id].present?
      company.deals.active
    else
      current_user.deals.active
    end
  end

  def time_period
    if params[:time_period_id]
      @time_period = company.time_periods.find(params[:time_period_id])
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

  def deal_member_filter
    user = company.users.find params[:user_id]
    if user.user_type == SELLER
      company.deals.by_deal_team([user.id])
    elsif user.user_type == SALES_MANAGER
      company.deals.by_deal_team(user.teams_tree_members.ids)
    else
      company.deals.active
    end
  end

  def all_team_deals
    all_members_list = []
    if params[:team_id].to_i == 0
      return company.deals.active
    else
      selected_team = Team.find(params[:team_id])
      all_members_list = selected_team.all_members.collect{|member| member.id}
      all_members_list += selected_team.all_leaders.collect{|member| member.id}
    end
    company.deals.by_deal_team(all_members_list).uniq
  end

  def team
    if params[:team_id].present?
      company.teams.find(params[:team_id])
    elsif current_user.leader?
      company.teams.where(leader: current_user).first
    else
      current_user.team
    end
  end

  def suggest_deals
    return @search_deals if defined?(@search_deals)

    @search_deals = company.deals.where('deals.name ilike ?', "%#{params[:name]}%").limit(10)
  end

  def activity_deals
    return @activity_deals if defined?(@activity_deals)

    @activity_deals = company.deals.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end

  def quarters
    return @quarters if defined?(@quarters)

    @quarters = []
    @quarters << { start_date: Time.new(year, 1, 1), end_date: Time.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Time.new(year, 4, 1), end_date: Time.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Time.new(year, 7, 1), end_date: Time.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Time.new(year, 10, 1), end_date: Time.new(year, 12, 31), quarter: 4 }
    @quarters = @quarters.map do |quarter|
      quarter[:range] = quarter[:start_date] .. quarter[:end_date]
      quarter
    end
    @quarters
  end

  def year
    @year ||= if params[:year].present?
      params[:year].to_i
    elsif params[:time_period_id].present?
      time_period.start_date.year
    else
      nil
    end
  end
end
