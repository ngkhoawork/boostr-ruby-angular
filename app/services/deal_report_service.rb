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
          line << val['deal_stage_log_previous_stage_id']
          line << val['stage_id']
          csv << line
        end
      end
    end
  end

  # New Deals - (list of deals where created = target date)
  def new_deals
    Deal.where(created_at: target_date)
  end

  # Advanced Deals - (list of deals that changed sales stage on target date -use deal_stage_logs.created_at yesterday)
  def advanced_deals
    Deal.joins(:deal_stage_logs).where(deal_stage_logs: { created_at: target_date })
  end

  # Won Deals - (list of deals that went to 100% yesterday)
  def won_deals
    Deal.at_percent(100)
  end

  def lost_deals
    Deal.at_percent(100).closed
  end

  def report_data
    @report_data ||= {
                        new_deals: API::Deals::Collection.new(new_deals).to_hash['deals'],
                        advanced_deals: API::Deals::Collection.new(advanced_deals).to_hash['deals'],
                        won_deals: API::Deals::Collection.new(won_deals).to_hash['deals'],
                        lost_deals: API::Deals::Collection.new(lost_deals).to_hash['deals']
                      }
  end

  def csv_header
    [:deal_type, :deal_name, :advertiser_name, :budget, :start_date, :stage_name, :deal_stage_log_previous_stage_id, :stage_id]
  end
end