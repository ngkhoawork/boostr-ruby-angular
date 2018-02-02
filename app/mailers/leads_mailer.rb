class LeadsMailer < ApplicationMailer
  def new_leads_assignment(lead)
    @lead = lead

    mail(from: lead.email, to: lead.user.email, subject: 'New Lead Assignment')
  end

  def reminder_notification(lead)
    @lead = lead

    mail(from: lead.email, to: lead.user.email, subject: 'Reminder: New Lead Assignment Needs Action')
  end

  def reassignment_notification(lead)
    @lead = lead

    mail(from: lead.email, to: lead.user.email, subject: 'Lead Reassignment Notice')
  end
end
