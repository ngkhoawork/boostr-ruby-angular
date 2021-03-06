class ReportsMailer < ApplicationMailer
  default from: 'boostr <boostr@boostrcrm.com>'

  def deals_daily_mail(recipients, company_id)
    report_data = DealReportService.new(params: Date.yesterday, company_id: company_id).generate_report
    @new_deals = report_data[:new_deals]
    @stage_changed_deals = report_data[:stage_changed_deals]
    @won_deals = report_data[:won_deals]
    @lost_deals = report_data[:lost_deals]
    @budget_changed_deals = report_data[:budget_changed]
    mail(to: recipients, subject: 'Boostr Daily Pipeline Changes')
  end

  def dfp_report_mail(recipients, report_type, tot_rows_imported, tot_rows_with_errors)
    @tot_rows_imported = tot_rows_imported
    @tot_rows_with_errors = tot_rows_with_errors
    mail(to: recipients, subject: "Boostr DFP #{ report_type } import completed")
  end
end
