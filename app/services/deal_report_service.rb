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
          line << val['previous_stage']
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
  def deals_stage_audit
    company_audit_logs
      .by_type_of_change('Stage Change')
      .includes(auditable: :advertiser)
  end

  def stage_changed_deals
    ActiveModel::ArraySerializer.new(
      deals_stage_audit,
      each_serializer: Report::StageChangeDealsAuditLogsSerializer
    ).as_json
  end

  # Won Deals - (list of deals that went to 100% yesterday)
  def won_deals
    Deal.at_percent(100).where(company_id: company_id, closed_at: date_range )
  end

  def lost_deals
    Deal.at_percent(0).where(company_id: company_id, closed_at: date_range)
  end

  def deal_budget_audit
    company_audit_logs
      .by_type_of_change('Budget Change')
      .includes(auditable: :advertiser)
  end

  def company_audit_logs
    @_company_audit_logs ||=
      Company.find(company_id).audit_logs.in_created_at_range(date_range).by_auditable_type('Deal')
  end

  def budget_changed
    ActiveModel::ArraySerializer.new(
      deal_budget_audit,
      each_serializer: Report::BudgetChangeDealsAuditLogsSerializer
    ).as_json
  end

  def report_data
    @report_data ||= {
                        new_deals: API::Deals::Collection.new(new_deals).to_hash(new: true)['deals'],
                        stage_changed_deals: stage_changed_deals,
                        won_deals: API::Deals::Collection.new(won_deals).to_hash(new: false)['deals'],
                        lost_deals: API::Deals::Collection.new(lost_deals).to_hash(new: false)['deals'],
                        budget_changed: budget_changed
                      }
  end

  def date_range
    return target_date.midnight..target_date.end_of_day unless target_date.kind_of? Hash

    DateTime.parse(target_date[:start_date])..DateTime.parse(target_date[:end_date])
  end

  def csv_header
    [:deal_type, :deal_name, :advertiser_name, :budget, :start_date, :stage_name, :previous_stage]
  end
end
