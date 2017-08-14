class DealReportService < BaseService
  NEW_DEALS      = 'New deals'.freeze
  WON_DEALS      = 'Won deals'.freeze
  LOST_DEALS     = 'Lost deals'.freeze
  BUDGET_CHANGED = 'Budget changed'.freeze
  STAGE_CHANGED  = 'Stage changed deals'.freeze

  def generate_report
    report_data
  end

  def generate_csv_report
    CSV.generate do |csv|
      csv << csv_header

      report_data.each do |key, vals|
        next if vals == [] || vals == nil
        deal_type = key.to_s.humanize

        vals.each do |val|
          val = val.symbolize_keys

          line = []
          line = [deal_type]
          line << val[:name]
          line << val[:advertiser_name]
          line << val[:budget]
          line << val[:start_date]
          line << val[:stage_name]
          line << val[:previous_stage]
          csv << line
        end
      end
    end
  end

  # New Deals - (list of deals where created = target date)
  def new_deals
    Deal.where(created_at: date_range, company_id: company_id)
  end

  def new_deals_report
    if change_type.present? && change_type.eql?(NEW_DEALS)
      API::Deals::Collection.new(new_deals).to_hash(new: true)['deals']
    end
  end

  # Advanced Deals - (list of deals that changed sales stage on target date -use deal_stage_logs.created_at yesterday)
  def deals_stage_audit
    company_audit_logs
      .by_type_of_change(AuditLog::STAGE_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def stage_changed_deals
    if change_type.present? && change_type.eql?(STAGE_CHANGED)
      ActiveModel::ArraySerializer.new(
        deals_stage_audit,
        each_serializer: Report::StageChangeDealsAuditLogsSerializer
      ).as_json
    end
  end

  # Won Deals - (list of deals that went to 100% yesterday)
  def won_deals
    Deal.at_percent(100).where(company_id: company_id, closed_at: date_range )
  end

  def won_deals_report
    if change_type.present? && change_type.eql?(WON_DEALS)
      API::Deals::Collection.new(won_deals).to_hash(new: false)['deals']
    end
  end

  def lost_deals
    Deal.at_percent(0).where(company_id: company_id, closed_at: date_range)
  end

  def lost_deals_report
    if change_type.present? && change_type.eql?(LOST_DEALS)
      API::Deals::Collection.new(lost_deals).to_hash(new: false)['deals']
    end
  end

  def deal_budget_audit
    company_audit_logs
      .by_type_of_change(AuditLog::BUDGET_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def company_audit_logs
    @_company_audit_logs ||=
      Company.find(company_id).audit_logs.in_created_at_range(date_range).by_auditable_type('Deal')
  end

  def budget_changed
    if change_type.present? && change_type.eql?(BUDGET_CHANGED)
      ActiveModel::ArraySerializer.new(
        deal_budget_audit,
        each_serializer: Report::BudgetChangeDealsAuditLogsSerializer
      ).as_json
    end
  end

  def report_data
    @report_data ||= {
                        new_deals: new_deals_report,
                        stage_changed_deals: stage_changed_deals,
                        won_deals: won_deals_report,
                        lost_deals: lost_deals_report,
                        budget_changed: budget_changed
                      }
  end

  def date_range
    return params.midnight..params.end_of_day unless params.kind_of? Hash

    DateTime.parse(params[:start_date])..DateTime.parse(params[:end_date])
  end

  def csv_header
    [:deal_type, :deal_name, :advertiser_name, :budget, :start_date, :stage_name, :previous_stage]
  end

  def change_type
    @_change_type ||= params[:change_type]
  end
end
