class LeadsMailer < ApplicationMailer
  default from: '<admin@boostr.com>'

  def new_leads_assignment(lead)
    @lead = lead

    mail(to: lead.user.email, subject: 'New Lead Assignment')
  end

  def reminder_notification(lead)
    @lead = lead

    mail(to: lead.user.email, subject: 'Reminder: New Lead Assignment Needs Action')
  end

  def reassignment_notification(lead)
    @lead = lead

    mail(to: lead.user.email, subject: 'Lead Reassignment Notice')
  end
end
