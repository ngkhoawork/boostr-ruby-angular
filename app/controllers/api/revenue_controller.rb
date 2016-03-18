class Api::RevenueController < ApplicationController
  respond_to :json

  def index
    if params[:time_period_id].present?
      render json: crevenues
    else
      render json: revenues
    end
  end

  def create
    csv_file = IO.read(params[:file].tempfile.path)
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

  def team
    if current_user.leader?
      current_user.teams.first
    else
      current_user.team
    end
  end

  def revenues
    rss = []
    if params[:filter] == 'all' && current_user.leader?
      rss = current_user.company.revenues
    elsif params[:filter] == 'team'
      team.members.each do |m|
        m.clients.each do |c|
          c.revenues.each do |r|
            rss += [r] if !rss.include?(r)
          end
        end
      end
    elsif params[:filter] == 'upside'
      if current_user.leader?
        current_user.teams.first.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance > 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
        current_user.teams.first.all_leaders.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance > 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
      else
        current_user.clients.each do |c|
          if c.client_members.where(user_id: current_user.id).first.share > 0
            c.revenues.where("revenues.balance > 0").each do |r|
              rss += [r] if !rss.include?(r)
            end
          end
        end
      end
    elsif params[:filter] == 'risk'
      if current_user.leader?
        current_user.teams.first.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance < 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
        current_user.teams.first.all_leaders.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance < 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
      else
        current_user.clients.each do |c|
          if c.client_members.where(user_id: current_user.id).first.share > 0
            c.revenues.where("revenues.balance < 0").each do |r|
              rss += [r] if !rss.include?(r)
            end
          end
        end
      end
    else # mine/default
      current_user.clients.each do |c|
        c.revenues.each do |r|
          rss += [r] if !rss.include?(r)
        end
      end
    end
    return rss
  end

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

  def crevenues
    return @crevenues if defined?(@crevenues)
    
    @crevenues = []
    member_or_team.all_revenues_for_time_period(start_date, end_date).each do |rs|
      if rs.kind_of?(Array)
        rs.flatten.each do |r|
          cr = @crevenues.find{ |i| i.client_id == r.client_id }
          if cr.present?
            cr.add_sum_budget(r.budget)
            cr.add_sum_period_budget(r.period_budget)
          else
            @crevenues += [r]
          end
        end
      else
        cr = @crevenues.find{ |i| i.client_id == rs.client_id }
        if cr.present?
          cr.add_sum_budget(rs.budget)
          cr.add_sum_period_budget(rs.period_budget)
        else
          @crevenues += [rs]
        end
      end
    end
    @crevenues.flatten
  end

end
