require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe UserMailer, :type => :mailer do
  describe 'lost deal email' do
    before do
      field = create :field, {
        subject_type: 'Deal',
        name: 'Close Reason',
        value_type: 'Option',
        locked: true,
        company: company
      }

      option = create :option, name: 'Price', field: field, company: company
      closed_stage = create :lost_stage
      deal.update(
        stage: closed_stage, 
        values_attributes: [{field_id: field.id, option_id: option.id, value: nil}],
        closed_reason_text: 'too high'
      )
      @deal_budget = number_to_currency(deal.budget_loc.to_i, precision: 0, unit: deal.currency.curr_symbol)
      @mail = UserMailer.lost_deal_email(['manager@boostrcrm.com'], deal)
    end

    it 'sends users lost deal notification' do
      expect(@mail.subject).to eq "A #{@deal_budget} deal for #{deal.advertiser_name} was lost"
      expect(@mail.to).to eq ['manager@boostrcrm.com']
      expect(@mail.from).to eq ['noreply@boostrcrm.com']
      expect(@mail.body.encoded).to include "#{deal.name} deal for #{deal.advertiser_name} with budget #{@deal_budget} was lost."
      expect(@mail.body.encoded).to include "Loss Reason - Price"
      expect(@mail.body.encoded).to include "Loss Comments - too high"
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def deal_members
    @_deal_members ||= create_list :deal_member, 2
  end

  def deal
    @_deal ||= create :deal, company: company, deal_members: deal_members
  end
end 