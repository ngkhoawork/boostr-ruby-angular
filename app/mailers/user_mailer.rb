class UserMailer < ApplicationMailer
  include ActionView::Helpers::NumberHelper
  default from: 'boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, subject, deal)
    @deal = deal
    mail(to: recipients, subject: subject)
  end

  def stage_changed_email(recipients, subject, deal_id)
    @deal = Deal.find(deal_id)
    mail(to: recipients, subject: subject)
  end

  def new_deal_email(recipients, deal_id)
    @deal = Deal.find(deal_id)
    subject = "A new $#{@deal.budget.nil? ? 0 : number_with_delimiter(@deal.budget / 100, :delimiter => ',')} deal for #{@deal.advertiser.present? ? @deal.advertiser.name : ""} just added to the pipeline"
    mail(to: recipients, subject: subject)
  end
end
