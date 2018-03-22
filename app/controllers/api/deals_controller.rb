class Api::DealsController < ApplicationController
  respond_to :json, :zip

  before_filter :set_current_user, only: [:update, :create]

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
          render json: suggest_deals
        elsif params[:activity].present?
          render json: activity_deals
        elsif params[:time_period_id].present?
          if valid_time_period?
            if params[:product_ids].present?
              render json: product_forecast_deals
            else
              render json: forecast_deals
            end
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
          render json: ActiveModel::ArraySerializer.new(
            deals.for_client(params[:client_id]).eager_load(
              :advertiser,
              :agency,
              :stage,
              :deal_custom_field,
              :users,
              :currency
            ).distinct,
            each_serializer: DealIndexSerializer
          )
      end
    }
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            # Something that should be interrupted if it takes too much time...
            deals = if params[:team_id].present?
              company.teams.find(params[:team_id])
            else
              company.deals
            end
            send_data Deal.to_csv(deals, company), filename: "deals-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def pipeline_report_totals
    deals = pipeline_report_relation
      .includes(:stageinfo)
      .except(:limit, :order, :offset, :preload)
      .pluck_to_struct(:id, :budget, 'stages.probability as probability')

    unweighted = deals.map{ |d| d.budget }.compact.reduce(:+).to_f
    weighted = deals.map{ |d| d.budget.to_f * d.probability / 100 }.compact.reduce(:+)
    ratio = ((weighted / unweighted * 100) / 100).round(2) rescue 0

    totals = {
      pipeline_unweighted: unweighted.round,
      pipeline_weighted: weighted.round,
      ratio: ratio,
      total_deals: deals.length,
      average_deal_size: (unweighted.round / deals.length rescue 0)
    }

    render json: {totals: totals}
  end

  def pipeline_report_monthly_budgets
    deal_ids = pipeline_report_relation.collect{|deal| deal.id}

    monthly_budgets = DealProductBudget
    .joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
    .where("deal_products.deal_id in (?)", deal_ids)
    .for_product_id(product_filter)
    .order("start_date asc")
    .group_by{|budget| budget.start_date.beginning_of_month}
    .collect{|key, value| {key => value.map(&:budget).compact.reduce(:+)} }
    .reduce(:merge)

    render json: { monthly_budgets: monthly_budgets }
  end

  def pipeline_report
    respond_to do |format|
      filtered_deals = pipeline_report_relation

      format.json {
        deal_ids = filtered_deals.to_a.collect{|deal| deal.id}

        range = DealProductBudget
        .joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
        .select("distinct(start_date)")
        .where("deal_products.deal_id in (?)", deal_ids)
        .order("start_date asc")
        .collect{|deal_product_budget| deal_product_budget.start_date&.beginning_of_month}
        .compact
        .uniq

        deal_settings_fields = company.fields.where(subject_type: 'Deal').pluck(:id, :name)

        deal_list = ActiveModel::ArraySerializer.new(
          filtered_deals,
          each_serializer: DealReportSerializer,
          deal_settings_fields: deal_settings_fields,
          product_filter: product_filter,
          company_teams_data: company_teams_data,
          range: range
        )

        response.headers['X-Total-Count'] = filtered_deals.except(:limit, :order, :offset, :preload).count.to_s
        render json: [{deals: deal_list, range: range}].to_json
      }
      format.csv {
        require 'timeout'
        begin
          Timeout::timeout(240) {
            send_data Deal.to_pipeline_report_csv(
              filtered_deals.except(:limit, :order, :offset), company, product_filter
            ), filename: "pipeline-report-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def pipeline_report_relation
    result = deals
      .by_stage_ids(params[:stage_ids])
      .for_time_period(time_period&.start_date, time_period&.end_date)
      .with_all_options(deal_type_source_params)
      .limit(limit)
      .offset(offset)
      .order(:name)
      .preload(
        :advertiser,
        :latest_happened_activity,
        :stageinfo,
        :deal_product_budgets,
        :deal_custom_field,
        agency: [:parent_client],
        deal_members_share_ordered: [:username],
        values: [:option]
      )
      .active
      .distinct

    # Filter by product id
    if product_filter
      result = result.joins('LEFT JOIN deal_products on deal_products.deal_id = deals.id').where(deal_products: { product_id: product_filter })
    end
    result
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
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Deal',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    else
      @deal = company.deals.new(deal_params)

      deal.created_by = current_user.id
      deal.updated_by = current_user.id
      # deal.set_user_currency
      if deal.save(context: :manual_update)
        render json: deal, status: :created
      else
        render json: { errors: deal.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    deal.updated_by = current_user.id
    deal.assign_attributes(deal_params)

    if deal.save(context: :manual_update)
      render deal
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal.destroy

    render nothing: true

  rescue ActiveRecord::DeleteRestrictionError => e
    render json: { errors: { delete: ["Please delete #{deal.include_pmp_product? ? 'PMP' : 'IO'} for this deal before deleting"] } }, status: :unprocessable_entity
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

  def won_deals
    render json: company_won_deals.as_json(override: true, options: { only: [:id, :name] })
  end

  def filter_data
    render json: FilterData::BaseSerializer.new(company).serializable_hash
  end

  def all
    render json: ActiveModel::ArraySerializer.new(serialized_deals, each_serializer: DealIndexSerializer)
  end

  def all_deals_header
    render json: {
      deals_info: deals_info_by_stage,
      stages: team_stages
    }
  end

  private

  def forecast_deals
    response_deals = []
    all_users = []
    if params[:user_id].present? && params[:user_id] != 'all'
      response_deals = user.deals
      all_users << user.id
    elsif params[:team_id].present? && params[:team_id] == 'all'
      response_deals = company.deals
      all_users = company.users.pluck(:id)
    else
      response_deals = all_team_deals
      selected_team = Team.find(params[:team_id])
      all_users = selected_team.all_members.map(&:id)
      all_users += selected_team.all_leaders.map(&:id)
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

      deal_object = Deal.find(deal['id'])
      sum_period_budget, split_period_budget = 0, 0

      deal_users = deal_object.users.pluck(:id)
      deal_filtered_users = all_users & deal_users
      result = deal_object.in_period_open_amt(time_period.start_date, time_period.end_date)
      sum_period_budget += result
      deal_object.deal_members.where("user_id in (?)", deal_filtered_users).each do |deal_member|
        split_period_budget += result * deal_member.share / 100.0
      end

      deal['period_budget'] = sum_period_budget
      deal['split_period_budget'] = split_period_budget
      deal['month_amounts'] = []
      monthly_revenues = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id")
        .select("date_part('month', start_date) as month, sum(deal_product_budgets.budget) as revenue")
        .for_time_period(time_period.start_date, time_period.end_date)
        .where("deal_products.deal_id = ? AND deal_products.open IS TRUE", deal['id'])
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
        .where("deal_id = ? AND deal_products.open IS TRUE", deal['id'])
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

  def product_forecast_deals
    response_deals = []
    all_users = []
    if params[:user_id].present? && params[:user_id] != 'all'
      response_deals = user.deals
      all_users << user.id
    elsif params[:team_id].present? && params[:team_id] == 'all'
      response_deals = company.deals
      all_users = company.users.pluck(:id)
    else
      response_deals = all_team_deals
      selected_team = Team.find(params[:team_id])
      all_users = selected_team.all_members.map(&:id)
      all_users += selected_team.all_leaders.map(&:id)
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
                              }
                      }
              }}
     )

    year = time_period.start_date.year
    data = []
    response_deals.each do |deal|
      range = deal['start_date'] .. deal['end_date']

      deal_object = Deal.find(deal['id'])

      product_deals = {}
      deal_object.deal_products.for_product_ids(product_ids).each do |deal_product|
        item_product_id = deal_product.product_id
        deal_product.deal_product_budgets.for_time_period(time_period.start_date, time_period.end_date).each do |deal_product_budget|
          if product_deals[item_product_id].nil?
            product_deals[item_product_id] = JSON.parse(JSON.generate(deal))
            product_deals[item_product_id][:product_id] = item_product_id
            product_deals[item_product_id][:product] = deal_product.product
            product_deals[item_product_id][:in_period_amt] = 0
          end
          if deal_product_budget.deal_product.open == true
            from = [time_period.start_date, deal_product_budget.start_date].max
            to = [time_period.end_date, deal_product_budget.end_date].min
            num_days = (to.to_date - from.to_date) + 1
            product_deals[item_product_id][:in_period_amt] += deal_product_budget.daily_budget.to_f * num_days
          end
        end
      end

      data = data + product_deals.values
    end

    data
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
        :next_steps_due,
        :initiative_id,
        :closed_reason_text,
        :created_at,
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
                :currency8,
                :currency9,
                :currency10,
                :currency_code1,
                :currency_code2,
                :currency_code3,
                :currency_code4,
                :currency_code5,
                :currency_code6,
                :currency_code7,
                :currency_code8,
                :currency_code9,
                :currency_code10,
                :text1,
                :text2,
                :text3,
                :text4,
                :text5,
                :text6,
                :text7,
                :text8,
                :text9,
                :text10,
                :note1,
                :note2,
                :note3,
                :note4,
                :note5,
                :note6,
                :note7,
                :note8,
                :note9,
                :note10,
                :datetime1,
                :datetime2,
                :datetime3,
                :datetime4,
                :datetime5,
                :datetime6,
                :datetime7,
                :datetime8,
                :datetime9,
                :datetime10,
                :number1,
                :number2,
                :number3,
                :number4,
                :number5,
                :number6,
                :number7,
                :number8,
                :number9,
                :number10,
                :integer1,
                :integer2,
                :integer3,
                :integer4,
                :integer5,
                :integer6,
                :integer7,
                :integer8,
                :integer9,
                :integer10,
                :boolean1,
                :boolean2,
                :boolean3,
                :boolean4,
                :boolean5,
                :boolean6,
                :boolean7,
                :boolean8,
                :boolean9,
                :boolean10,
                :percentage1,
                :percentage2,
                :percentage3,
                :percentage4,
                :percentage5,
                :percentage6,
                :percentage7,
                :percentage8,
                :percentage9,
                :percentage10,
                :dropdown1,
                :dropdown2,
                :dropdown3,
                :dropdown4,
                :dropdown5,
                :dropdown6,
                :dropdown7,
                :dropdown8,
                :dropdown9,
                :dropdown10,
                :sum1,
                :sum2,
                :sum3,
                :sum4,
                :sum5,
                :sum6,
                :sum7,
                :sum8,
                :sum9,
                :sum10,
                :number_4_dec1,
                :number_4_dec2,
                :number_4_dec3,
                :number_4_dec4,
                :number_4_dec5,
                :number_4_dec6,
                :number_4_dec7,
                :number_4_dec8,
                :number_4_dec9,
                :number_4_dec10,
                :link1,
                :link2,
                :link3,
                :link4,
                :link5,
                :link6,
                :link7,
                :link8,
                :link9,
                :link10
            ]
        }
    ).merge(modifying_user: current_user)
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
      company.deals
    elsif params[:filter] == 'all'
      company.deals
    elsif params[:filter] == 'selected_team' && params[:team_id]
      all_team_deals
    elsif params[:filter] == 'user' && params[:user_id]
      deal_member_filter
    elsif params[:filter] == 'team'
      if team.present?
        company.deals.by_deal_team(team.all_members.map(&:id) + team.all_leaders.map(&:id))
      else
        company.deals
      end
    elsif params[:client_id].present?
      company.deals
    else
      current_user.deals
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
      company.deals
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

  def suggest_deals
    @_search_deals ||= company.deals.by_name(params[:name]).limit(10)
  end

  def activity_deals
    @_activity_deals ||= company.deals.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
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

  def company_won_deals
    company.deals.won.by_name(params[:name])
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def serialized_deals
    team_stages.reduce([]) do |arr, stage|
      ordered_deals = all_ordered_deals_by_stage(stage)

      arr << ordered_deals.limit(limit).offset(offset).includes(
          :advertiser,
          :agency,
          :deal_custom_field,
          :users,
          :stage,
          :currency
        )
    end.flatten
  end

  def deals_info_by_stage
    team_stages.reduce({}) do |res, stage|
      ordered_deals = all_ordered_deals_by_stage(stage)

      unweighted_budget = ordered_deals.sum(:budget)
      weighted_budget = stage.probability.zero? ? 0 : unweighted_budget * (stage.probability.to_f / 100.to_f)

      res.tap do |obj|
        obj[stage.id] = {
          count: ordered_deals.count,
          unweighted: unweighted_budget.to_i,
          weighted: weighted_budget.to_i
        }
      end
    end
  end

  def all_ordered_deals_by_stage(stage)
    deals_with_stage = deals.where(stage: stage)
      .by_seller_id(params[:member_id])
      .by_team_id(params[:team_id])
      .for_client(params[:advertiser_id])
      .for_client(params[:agency_id])
      .by_budget_range(params[:budget_from], params[:budget_to])
      .by_curr_cd(params[:curr_cd])
      .by_start_date(params[:start_start_date], params[:start_end_date])
      .for_time_period(time_period&.start_date, time_period&.end_date)
      .by_created_date(params[:created_start_date], params[:created_end_date])
      .distinct

    closed_year = Date.new(params[:closed_year].to_i) if params[:closed_year].present?

    stage.open? ? deals_with_stage.order(:start_date) : deals_with_stage.by_closed_at(closed_year).order(closed_at: :desc)
  end

  def company_teams_data
    company.teams.pluck_to_struct(:id, :name, :leader_id)
  end

  def team_stages
    @_team_stages ||= team&.sales_process&.stages&.active || company.default_sales_process&.stages&.active || []
  end
end
