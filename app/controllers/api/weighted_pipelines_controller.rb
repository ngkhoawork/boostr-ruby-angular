class Api::WeightedPipelinesController < ApplicationController
  respond_to :json

  def show
    render json: weighted_pipeline
  end

  protected

  def time_period
    return @time_period if defined?(@time_period)
    @time_period = current_user.company.time_periods.find(params[:time_period_id])
  end

  def member
    return @member if defined?(@member)

    if current_user.leader?
      @member = current_user.company.users.find(params[:id])
    elsif params[:id] == current_user.id
      @member = current_user
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def deals
    return @deals if defined?(@deals)

    @deals = member.deals.for_time_period(time_period)
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = deals.map{|d| d.as_weighted_pipeline(time_period)}
  end
end
