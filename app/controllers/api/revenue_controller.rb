class Api::RevenueController < ApplicationController
  respond_to :json

  def index
    if params[:time_period_id].present?
      render json: crevenues
    elsif params[:year].present?
      render json: quarterly_ios
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

  def quarterly_revenues
    revs = current_user.company.revenues
      .where("date_part('year', start_date) <= ? AND date_part('year', end_date) >= ?", year, year)
      .as_json
    revs.map do |revenue|
      revenue[:quarters] = []
      revenue[:year] = year
      if revenue['end_date'] == revenue['start_date']
        revenue['end_date'] += 1.day
      end
      revenue_range = revenue['start_date'] .. revenue['end_date']
      revenue['months'] = []
      month = Date.parse("#{year-1}1201")
      while month = month.next_month and month.year == year do
        month_range = month.at_beginning_of_month..month.at_end_of_month
        if month_range.overlaps? revenue_range
          overlap = [revenue['start_date'], month_range.begin].max..[revenue['end_date'], month_range.end].min
          revenue['months'].push((overlap.end.to_time - overlap.begin.to_time) / (revenue['end_date'].to_time - revenue['start_date'].to_time))
        else
          revenue['months'].push 0
        end
      end

      quarters.each do |quarter|
        if quarter[:range].overlaps? revenue_range
          overlap = [revenue['start_date'], quarter[:start_date]].max..[revenue['end_date'], quarter[:end_date]].min
          revenue[:quarters].push ((overlap.end - overlap.begin)  / (revenue['end_date'] - revenue['start_date']))
        else
          revenue[:quarters].push 0
        end
      end
    end
    revs
  end

  def quarterly_ios
    ios = current_user.company.ios
    .where("date_part('year', start_date) <= ? AND date_part('year', end_date) >= ?", year, year)
    .as_json
    ios.map do |io|
      io_obj = Io.find(io['id'])
      io[:quarters] = [0, 0, 0, 0]
      io[:year] = year
      io['months'] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      total = 0
      if io['end_date'] == io['start_date']
        io['end_date'] += 1.day
      end

      io_obj.content_fee_product_budgets.where("date_part('year', start_date) = ?", year).each do |content_fee_product_budget|
        month = content_fee_product_budget.start_date.mon
        io['months'][month - 1] += content_fee_product_budget.budget
        io[:quarters][(month - 1) / 3] += content_fee_product_budget.budget
        total += content_fee_product_budget.budget
      end

      io['budget'] = total
    end
    ios
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

    @crevenues = member_or_team.crevenues(start_date, end_date)
    @crevenues
  end

end
