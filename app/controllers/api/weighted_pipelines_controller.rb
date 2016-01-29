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
    @quarters << { start_date: Time.new(year, 1, 1), end_date: Time.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Time.new(year, 4, 1), end_date: Time.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Time.new(year, 7, 1), end_date: Time.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Time.new(year, 10, 1), end_date: Time.new(year, 12, 31), quarter: 4 }
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
    elsif params[:member_id] == current_user.id.to_s
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

    @deals = member_or_team.all_deals_for_time_period(start_date, end_date).flatten.uniq
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = deals.map{|d| d.as_weighted_pipeline(start_date, end_date)}
  end
end
