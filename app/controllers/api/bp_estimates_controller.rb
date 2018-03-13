class Api::BpEstimatesController < ApplicationController
  respond_to :json

  def index
    if params[:client_id]
      revenues = AccountRevenueFact.where(company_id: company.id, account_dimension_id: params[:client_id])
      render json: { bp_estimates: bp_estimates, revenues: revenues }, status: :ok
    elsif bp.present?
      time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date, bp.time_period.end_date).to_a
      year_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date - 1.years, bp.time_period.end_date -  1.years).to_a
      prev_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", (bp.time_period.start_date - 3.months).beginning_of_month, (bp.time_period.end_date -  3.months).end_of_month).to_a
      pipelines = []
      revenues = []
      year_pipelines = []
      year_revenues = []
      prev_pipelines = []
      prev_revenues = []
      year_time_period = nil
      prev_time_period = nil
      if time_dimensions.count > 0
        pipelines = apply_filters_for_account_pipeline_facts(bp.company.id, time_dimensions[0].id)
        revenues = apply_filters_for_account_revenue_facts(bp.company.id, time_dimensions[0].id)
      end
      if year_time_dimensions.count > 0
        year_time_periods = TimePeriod.where(company_id: company.id, start_date: year_time_dimensions[0].start_date, end_date: year_time_dimensions[0].end_date)
        if year_time_periods.count > 0
          year_pipelines = apply_filters_for_account_pipeline_facts(bp.company.id, year_time_dimensions[0].id)
          year_revenues = apply_filters_for_account_revenue_facts(bp.company.id, year_time_dimensions[0].id)
          year_time_period = year_time_periods[0]
        end
      end
      if prev_time_dimensions.count > 0
        prev_time_periods = TimePeriod.where(company_id: company.id, start_date: prev_time_dimensions[0].start_date, end_date: prev_time_dimensions[0].end_date)
        if prev_time_periods.count > 0
          prev_pipelines = apply_filters_for_account_pipeline_facts(bp.company.id, prev_time_dimensions[0].id)
          prev_revenues = apply_filters_for_account_revenue_facts(bp.company.id, prev_time_dimensions[0].id)
          prev_time_period = prev_time_periods[0]
        end
      end
      respond_to do |format|
        format.json {
          if limit.present? && offset.present?
            bp_data = bp_estimates.limit(limit).offset(offset)
          else
            bp_data = bp_estimates
          end
          render json: {
              bp_estimates: bp_data.collect{ |bp_estimate| bp_estimate.full_json },
              current: { pipelines: pipelines, revenues: revenues },
              year: { pipelines: year_pipelines, revenues: year_revenues, time_period: year_time_period },
              prev: { pipelines: prev_pipelines, revenues: prev_revenues, time_period: prev_time_period }
          }, status: :ok
        }
        format.csv {
          require 'timeout'
          begin
            status = Timeout::timeout(120) {
              send_data BpEstimate.to_csv(bp, bp_estimates, company), filename: "bp-estimates-#{Date.today}.csv"
            }
          rescue Timeout::Error
            return
          end
        }
      end
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def status
    total_seller_estimate = bp_estimates
      .assigned
      .collect{|bp_estimate| bp_estimate.estimate_seller || 0}
      .inject(0){|sum,x| sum + x }.to_s
    total_mgr_estimate = bp_estimates
      .assigned.collect{|bp_estimate| bp_estimate.estimate_mgr || 0}
      .inject(0){|sum,x| sum + x }
    total_status = bp_estimates
      .has_status
      .select('distinct(client_id)')
      .count
    total_clients = bp_estimates
      .select('distinct(client_id)')
      .count
    render json: {
      total_seller_estimate: total_seller_estimate,
      total_mgr_estimate: total_mgr_estimate,
      total_status: total_status,
      total_clients: total_clients
    }, status: :ok
  end

  def create
    bp_estimate = bp.bp_estimates.new(bp_estimate_params)
    # bp_estimate.update_periods if params[:bp_estimate][:bp_estimate_budgets_attributes]
    if bp_estimate.save
      # bp.update_total_budget
      render json: bp
    else
      render json: { errors: bp_estimate.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if bp_estimate.update_attributes(bp_estimate_params)
      bp_estimate = bp.bp_estimates.find(params[:id])
      render json: bp_estimate.as_json({
         include: {
             bp_estimate_products: {
                 include: {
                     product: {}
                 }
             },
             client: {},
             user: {}
         },
         methods: [:client_name, :user_name]
      })
    else
      render json: { errors: bp_estimate.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    bp_estimate.destroy
    # bp.update_total_budget
    render json: bp
  end

  private

  def company
    current_user.company
  end

  def bp
    @bp ||= current_user.company.bps.find(params[:bp_id])
  end

  def team
    @team ||= current_user.company.teams.find_by(id: params[:team_id])
  end

  def user
    @user ||= current_user.company.users.find_by(id: params[:user_id])
  end

  def bp_estimate
    @bp_estimate ||= bp.bp_estimates.find(params[:id])
  end

  def limit
    params[:per].to_i if params[:per].present?
  end

  def offset
    (params[:page].to_i - 1) * limit if params[:page].present?
  end

  def bp_estimates
    return @bp_estimates if defined?(@bp_estimates)
    incomplete = false
    completed = false
    if params[:incomplete] == "true"
      incomplete = true
    elsif params[:incomplete] == "false"
      completed = true
    end
    unassigned = false
    if params[:unassigned] == "true"
      unassigned = true
    end
    if params[:client_id]
      @bp_estimates = company.bp_estimates.where(client_id: params[:client_id]).as_json({
               include: {
                       user: {
                               only: [:id, :email, :first_name, :last_name]
                       },
                       bp: {
                               include: {
                                       time_period: {
                                               only: [:id, :name]
                                       }
                               }
                       },
                       bp_estimate_products: {}
               },
               methods: [:time_dimension]
       })
    else
      @bp_estimates = bp.bp_estimates
        .find_by_client_name(params[:client_name])
        .unassigned(unassigned)
        .incomplete(incomplete)
        .completed(completed)
        .by_user_ids(member_ids)
        .order_by_client_name
        .includes(
          {
            bp_estimate_products: {
              product: {},
            }
          },
          :user,
          :client
        )
    end
  end

  def apply_filters_for_account_pipeline_facts(company_id, time_dimension_id)
    AccountPipelineFactQuery.new(
      company_id: company_id,
      time_dimension_id: time_dimension_id,
      client_name: params[:client_name]
    ).perform
  end

  def apply_filters_for_account_revenue_facts(company_id, time_dimension_id)
    AccountRevenueFactQuery.new(
      company_id: company_id,
      time_dimension_id: time_dimension_id,
      client_name: params[:client_name]
    ).perform
  end

  def member_ids
    @_member_ids ||= case params[:filter]
      when 'my'
        [current_user.id]
      when 'team'
        current_user.teams.map(&:all_members_and_leaders).flatten
      else
        if user.present?
          [user.id]
        elsif team.present?
          team.all_members_and_leaders
        else
          nil
        end
      end
  end

  def bp_estimate_params
    params.require(:bp_estimate).permit(
        :bp_id,
        :client_id,
        :user_id,
        :estimate_seller,
        :estimate_mgr,
        :objectives,
        :assumptions,
        {
            bp_estimate_products_attributes: [:id, :estimate_seller, :estimate_mgr]
        }
    )
  end
end
