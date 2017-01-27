class DealReportService < BaseService

  def generate_report
    report_data
  end

  def generate_csv_report
    CSV.generate do |csv|
      csv << csv_header
      report_data.each do |key, val|
        next if val == []
        deal_type = key.to_s.humanize
        val.each do |val|
          line = []
          line = [deal_type]
          line << val['name']
          line << val['advertiser_name']
          line << val['budget']
          line << val['start_date']
          line << val['stage_name']
          line << val['deal_stage_log_previous_stage']
          csv << line
        end
      end
    end
  end

  # New Deals - (list of deals where created = target date)
  def new_deals
    Deal.where(created_at: date_range, company_id: company_id)
  end

  # Advanced Deals - (list of deals that changed sales stage on target date -use deal_stage_logs.created_at yesterday)
  def stage_changed_deals
    deal_stage_logs = DealStageLog.includes(:deal).where(created_at: date_range).where(deals: { company_id: company_id })
    ActiveModel::ArraySerializer.new(deal_stage_logs, each_serializer: DealChangedSerializer).as_json
  end

  # Won Deals - (list of deals that went to 100% yesterday)
  def won_deals
    Deal.at_percent(100).where(company_id: company_id, closed_at: date_range )
  end

  def lost_deals
    Deal.at_percent(0).where(company_id: company_id, closed_at: date_range)
  end

  def budget_changed
    deal_logs =  DealLog.includes(:deal).where(created_at: date_range).where(deals: { company_id: company_id })
    ActiveModel::ArraySerializer.new(deal_logs, each_serializer: BudgetChangeSerializer).as_json
  end

  def report_data
    @report_data ||= {
                        new_deals: API::Deals::Collection.new(new_deals).to_hash['deals'],
                        stage_changed_deals: stage_changed_deals,
                        won_deals: API::Deals::Collection.new(won_deals).to_hash['deals'],
                        lost_deals: API::Deals::Collection.new(lost_deals).to_hash['deals'],
                        budget_changed: budget_changed
                      }
  end

  def date_range
    return target_date unless target_date.kind_of? Hash
    Date.parse(target_date[:start_date]).end_of_day..Date.parse(target_date[:end_date]).end_of_day
  end

  def csv_header
    [:deal_type, :deal_name, :advertiser_name, :budget, :start_date, :stage_name, :deal_stage_log_previous_stage]
  end
end