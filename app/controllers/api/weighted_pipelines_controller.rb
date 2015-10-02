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

  def member_or_team
    return @member_or_team if defined?(@member_or_team)

    if params[:member_id]
      @member_or_team = member
    elsif params[:team_id]
      @member_or_team = team
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def member
    return @member if defined?(@member)

    if current_user.leader?
      @member = current_user.company.users.find(params[:member_id])
    elsif params[:member_id] == current_user.id
      @member = current_user
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def team
    return @team if defined?(@team)

    @team = current_user.company.teams.find(params[:team_id])
  end

  def deals
    return @deals if defined?(@deals)

    @deals = member_or_team.all_deals_for_time_period(time_period).flatten.uniq
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = deals.map{|d| d.as_weighted_pipeline(time_period)}
  end
end
