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
    @_line_items ||=
      by_io_name
        .union(by_agency_name)
        .union(by_advertiser_name)
        .includes(:product, io: [:agency, :advertiser, :currency])
        .by_start_date(params[:start_date], params[:end_date])
  end

  def negative_line_items
    @_negative_line_items ||= line_items.where('display_line_items.balance < 0')
  end

  def positive_line_items
    @_positive_line_items ||= line_items.where('display_line_items.balance > 0')
  end

  def io_ids
    case params[:io_owner]
      when 'my'
        Io.joins(:io_members).where('io_members.user_id in (?)', current_user.id).pluck(:id)
      when 'teammates'
        Io.joins(:io_members).where('io_members.user_id in (?)', team_members_ids).pluck(:id)
      when 'all'
        Io.where(company_id: current_user.company_id).pluck(:id)
      else
        Io.where(company_id: current_user.company_id).pluck(:id)
    end
  end

  def team_members_ids
    member_ids = []

    current_user.teams.each do |t|
      member_ids += t.all_members.collect{ |m| m.id }
      member_ids += t.all_leaders.collect{ |m| m.id }
    end

    member_ids.uniq
  end

  def revenue_calculation_object
    {
        positive_balance_count: positive_line_items.count,
        positive_balance: sum_positive_line_items,
        negative_balance_count: negative_line_items.count,
        negative_balance: sum_negative_line_items
    }
  end

  def sum_positive_line_items
    positive_line_items.sum(:balance).to_i rescue nil
  end

  def sum_negative_line_items
    negative_line_items.sum(:balance).to_i rescue nil
  end

  def line_items_by_io_ids
    @_line_items_by_io_ids ||= DisplayLineItem.where('io_id in (?)', io_ids)
  end

  def by_io_name
    line_items_by_io_ids.by_io_name(params[:name])
  end

  def by_agency_name
    line_items_by_io_ids.by_agency_name(params[:name])
  end

  def by_advertiser_name
    line_items_by_io_ids.by_advertiser_name(params[:name])
  end
end
