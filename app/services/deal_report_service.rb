class DealReportService < BaseService
  NEW_DEALS           = 'New Deals'.freeze
  WON_DEALS           = 'Won Deals'.freeze
  LOST_DEALS          = 'Lost Deals'.freeze
  BUDGET_CHANGED      = 'Budget Changed'.freeze
  STAGE_CHANGED       = 'Stage Changed'.freeze
  START_DATE_CHANGED  = 'Start Date Changed'.freeze
  SHARE_CHANGED       = 'Share Changed'.freeze

  def generate_report
    report_data
  end

  def generate_csv_report
    CSV.generate do |csv|
      csv << csv_header

      report_data.each do |key, vals|
        next if vals == []
        deal_type = key.to_s.humanize

        vals.each do |val|
          val = val.symbolize_keys

          line = []
          line << (val[:date] + utc_offset.to_i.minutes).to_date
          line << val[:name]
          line << val[:advertiser_name]
          line << deal_type
          line << val[:old_value]
          line << val[:new_value]
          line << val[:budget]
          line << val[:budget_change]
          line << val[:start_date]
          line << val[:biz_days]
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
    if change_type.blank? || change_type.eql?(NEW_DEALS)
      API::Deals::Collection.new(new_deals).to_hash(new: true)['deals']
    else
      []
    end
  end

  # Advanced Deals - (list of deals that changed sales stage on target date -use deal_stage_logs.created_at yesterday)
  def deals_stage_audit
    company_audit_logs
      .by_type_of_change(AuditLog::STAGE_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def stage_changed_deals
    if change_type.blank? || change_type.eql?(STAGE_CHANGED)
      ActiveModel::ArraySerializer.new(
        deals_stage_audit,
        each_serializer: Report::StageChangeDealsAuditLogsSerializer
      ).as_json
    else
      []
    end
  end

  # Won Deals - (list of deals that went to 100% yesterday)
  def won_deals
    Deal.at_percent(100).where(company_id: company_id, closed_at: date_range )
  end

  def won_deals_report
    if change_type.blank? || change_type.eql?(WON_DEALS)
      API::Deals::Collection.new(won_deals).to_hash(new: false)['deals']
    else
      []
    end
  end

  def lost_deals
    Deal.at_percent(0).where(company_id: company_id, closed_at: date_range)
  end

  def lost_deals_report
    if change_type.blank? || change_type.eql?(LOST_DEALS)
      API::Deals::Collection.new(lost_deals).to_hash(new: false)['deals']
    else
      []
    end
  end

  def company_audit_logs
    @_company_audit_logs ||=
      Company.find(company_id).audit_logs.in_created_at_range(date_range).by_auditable_type('Deal')
  end

  def deal_budget_audit
    company_audit_logs
      .by_type_of_change(AuditLog::BUDGET_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def budget_changed
    if change_type.blank? || change_type.eql?(BUDGET_CHANGED)
      ActiveModel::ArraySerializer.new(
        deal_budget_audit,
        each_serializer: Report::BudgetChangeDealsAuditLogsSerializer
      ).as_json
    else
      []
    end
  end

  def deal_start_date_audit
    company_audit_logs
      .by_type_of_change(AuditLog::START_DATE_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def start_date_changed
    if change_type.blank? || change_type.eql?(START_DATE_CHANGED)
      ActiveModel::ArraySerializer.new(
        deal_start_date_audit,
        each_serializer: Report::StartDateChangeSerializer
      ).as_json
    else
      []
    end
  end

  def deal_member_added_audit
    company_audit_logs
      .by_type_of_change(AuditLog::MEMBER_ADDED_TYPE)
      .includes(auditable: :advertiser)
  end

  def member_added_changed
    if change_type.blank? || change_type.eql?(AuditLog::MEMBER_ADDED_TYPE)
      ActiveModel::ArraySerializer.new(
        deal_member_added_audit,
        each_serializer: Report::MemberAddedSerializer
      ).as_json
    else
      []
    end
  end

  def deal_member_removed_audit
    company_audit_logs
      .by_type_of_change(AuditLog::MEMBER_REMOVED_TYPE)
      .includes(auditable: :advertiser)
  end

  def member_removed_changed
    if change_type.blank? || change_type.eql?(AuditLog::MEMBER_REMOVED_TYPE)
      ActiveModel::ArraySerializer.new(
        deal_member_removed_audit,
        each_serializer: Report::MemberRemovedSerializer
      ).as_json
    else
      []
    end
  end

  def deal_share_change_audit
    company_audit_logs
      .by_type_of_change(AuditLog::SHARE_CHANGE_TYPE)
      .includes(auditable: :advertiser)
  end

  def share_change_report
    if change_type.blank? || change_type.eql?(SHARE_CHANGED)
      ActiveModel::ArraySerializer.new(
        deal_share_change_audit,
        each_serializer: Report::ShareChangedSerializer
      ).as_json
    else
      []
    end
  end

  def report_data
    @report_data ||= {
                        new_deals: new_deals_report,
                        stage_changed_deals: stage_changed_deals,
                        won_deals: won_deals_report,
                        lost_deals: lost_deals_report,
                        budget_changed: budget_changed,
                        start_date_changed: start_date_changed,
                        member_added: member_added_changed,
                        member_removed: member_removed_changed,
                        share_change: share_change_report
                      }
  end

  def date_range
    return params.midnight..params.end_of_day unless params.kind_of? Hash

    DateTime.parse(params[:start_date])..DateTime.parse(params[:end_date])
  end

  def csv_header
    [
      'Change Date',
      'Deal Name',
      'Advertiser Name',
      'Change Type',
      'Old Value',
      'New Value',
      'Budget',
      'Budget Change',
      'Deal Start Date',
      'Number Business Days'
    ]
  end

  def change_type
    @_change_type ||= params[:change_type]
  end

  def utc_offset
    @_utc_offset ||= params[:utc_offset]
  end
end
