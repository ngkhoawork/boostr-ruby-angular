class ReportsMailer < ApplicationMailer
  def deals_daily_mail(recipients, company_id)
    report_data = DealReportService.new(target_date: Date.yesterday, company_id: company_id).generate_report
    @new_deals = report_data[:new_deals]
    @advanced_deals = report_data[:advanced_deals]
    @won_deals = report_data[:won_deals]
    @lost_deals = report_data[:lost_deals]
    mail(to: recipients, subject: 'Boostr Daily Pipeline Changes')
  end
end