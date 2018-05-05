require 'open-uri'

class ContractMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'

  def ealert(recipients, contract_id, name, fields, assets, comment = '')
    @contract_id = contract_id
    @name = name
    @fields = fields
    @comment = comment

    set_attachments(assets)
    mail(to: recipients, subject: 'Contract EAlert')
  end

  private

  def set_attachments(assets)
    assets.each do |asset|
      attachments[asset[:name]] = open(asset[:url]).read
    end
  end
end
