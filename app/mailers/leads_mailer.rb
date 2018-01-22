class LeadsMailer < ApplicationMailer
  def new_leads_assignment(lead)
    @lead = lead

    mail(from: lead.email, to: lead.user.email, subject: 'New Lead Assignment')
  end
end
