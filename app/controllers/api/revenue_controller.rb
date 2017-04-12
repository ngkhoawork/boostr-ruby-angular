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

  def forecast_detail
    render json: quarterly_ios
  end

  def create
    csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

  private

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
    if params[:team_id] == 'all'
      ios = current_user.company.ios
                    .for_time_period(start_date, end_date)
                    .as_json
      year = start_date.year
      ios.map do |io|
        io_obj = Io.find(io['id'])
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
        total = 0
        io[:members] = io_obj.io_members
        share = io_obj.io_members.pluck(:share).sum

        if io['end_date'] == io['start_date']
          io['end_date'] += 1.day
        end

        io_obj.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
          month = content_fee_product_budget.start_date.mon
          io[:months][month - start_month] += content_fee_product_budget.budget
          io[:quarters][(month - start_month) / 3] += content_fee_product_budget.budget
          total += content_fee_product_budget.budget
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
            io[:months][index - start_month] += budget
            io[:quarters][(index - start_month) / 3] += budget
            total += budget
          end
        end

        io['in_period_amt'] = total
        io['in_period_split_amt'] = total * share / 100
      end

      ios
    else
      member_or_team.quarterly_ios(time_period.start_date, time_period.end_date)
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
    @time_period ||= current_user.company.time_periods.find(params[:time_period_id])
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

  def member
    @member ||= if params[:user_id]
      current_user.company.users.find(params[:user_id])
    elsif current_user.leader?
      current_user.company.users.find(params[:member_id])
    elsif params[:member_id] == current_user.id.to_s
      current_user
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def team
    @team ||= current_user.company.teams.find(params[:team_id])
  end

  def crevenues
    @crevenues ||= member_or_team.crevenues(start_date, end_date)
  end
end
