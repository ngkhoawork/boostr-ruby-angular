class DashboardPacingAlertService < BaseService

  def display_revenue
    revenue_calculation_object
  end

  def filtered_line_items
    if params[:filter]
      if params[:filter] == 'risk'
        negative_line_items
      elsif params[:filter] == 'upside'
        positive_line_items
      end
    end
  end

  def line_items
    @line_items ||= DisplayLineItem.where("io_id in (?)", io_ids)
  end

  def negative_line_items
    @negative_line_items ||= line_items.where('display_line_items.balance < 0')
  end

  def positive_line_items
    @positive_line_items ||= line_items.where('display_line_items.balance > 0')
  end

  def io_ids
    case params[:io_owner]
      when 'my'
        Io.joins(:io_members).where("io_members.user_id in (?)", current_user.id).pluck(:id)
      when 'teammates'
        Io.joins(:io_members).where("io_members.user_id in (?)", team_members_ids).pluck(:id)
      when 'all'
        Io.where(company_id: current_user.company_id).pluck(:id)
      else
        Io.where(company_id: current_user.company_id).pluck(:id)
    end
  end

  def team_members_ids
    member_ids = []
    current_user.teams.each do |t|
      member_ids += t.all_members.collect{|m| m.id}
      member_ids += t.all_leaders.collect{|m| m.id}
    end
    member_ids.uniq
  end

  def revenue_calculation_object
    {
        positive_balance_count: positive_line_items.count,
        positive_balance: positive_line_items.sum(:balance).to_i,
        negative_balance_count: negative_line_items.count,
        negative_balance: negative_line_items.sum(:balance).to_i
    }
  end
end