class Api::DealsController < ApplicationController
  respond_to :json, :zip

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
          render json: suggest_deals
        elsif params[:activity].present?
          render json: activity_deals
        elsif params[:year].present?
          response_deals = company.deals
            .includes(:deal_members)
            .where("date_part('year', start_date) <= ? AND date_part('year', end_date) >= ?", params[:year], params[:year])
            .as_json

          #deal_sums = company.deals
          #  .select("advertiser_id, sum(budget) AS budget")
          #  .where("date_part('year', start_date) <= ? AND date_part('year', end_date) >= ?", params[:year], params[:year])
          #  .group('deals.advertiser_id')
          #  .as_json
          response_deals = response_deals.map do |deal|
            range = deal['start_date'] .. deal['end_date']

            deal['month_amounts'] = []
            monthly_revenues = DealProduct.select("date_part('month', start_date) as month, (sum(budget)/100.0) as revenue").where("deal_id=? and date_part('year', start_date) = ?", deal['id'], params[:year]).group("date_part('month', start_date)").order("date_part('month', start_date) asc").collect {|deal| {month: deal.month.to_i, revenue: deal.revenue}}
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
            quarterly_revenues = DealProduct.select("date_part('quarter', start_date) as quarter, (sum(budget)/100.0) as revenue").where("deal_id=? and date_part('year', start_date) = ?", deal['id'], params[:year]).group("date_part('quarter', start_date)").order("date_part('quarter', start_date) asc").collect {|deal| {quarter: deal.quarter.to_i, revenue: deal.revenue}}
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
          render json: ActiveModel::ArraySerializer.new(deals.for_client(params[:client_id]).includes(:advertiser, :stage, :previous_stage).distinct , each_serializer: DealIndexSerializer).to_json
        end
      }
      format.zip {
        require 'timeout'
        begin
          status = Timeout::timeout(60) {
            # Something that should be interrupted if it takes too much time...
            if current_user.leader?
              deals = company.deals
            elsif team.present?
              deals = team.deals
            else
              deals = current_user.deals
            end
            send_data deals.to_zip, filename: "deals-#{Date.today}.zip"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def pipeline_report
    respond_to do |format|
      format.json {
        deal_list = ActiveModel::ArraySerializer.new(deals.includes(:advertiser, :agency, :stage, :previous_stage, :users, :deal_products).distinct , each_serializer: DealReportSerializer)
        deal_ids = deals.collect{|deal| deal.id}
        range = DealProduct.select("distinct(start_date)").where("deal_id in (?)", deal_ids).order("start_date asc").collect{|deal_product| deal_product.start_date}
        render json: [{deals: deal_list, range: range}].to_json
      }
      format.csv {
        send_data Deal.to_pipeline_report_csv(company), filename: "pipeline-report-#{Date.today}.csv"
      }
    end

  end

  def show
    deal
  end

  def create
    @deal = company.deals.new(deal_params)

    deal.created_by = current_user.id
    deal.updated_by = current_user.id

    if deal.save
      render json: deal, status: :created
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
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

  private

  def deal_params
    params.require(:deal).permit(:name, :stage_id, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :closed_at, :next_steps, { values_attributes: [:id, :field_id, :option_id, :value] })
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
    elsif params[:filter] == 'team' && team.present?
      team.deals
    else
      current_user.deals
    end
  end

  def team
    if current_user.leader?
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
    return nil if params[:year].blank?

    params[:year].to_i
  end
end
