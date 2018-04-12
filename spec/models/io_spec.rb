require 'rails_helper'

RSpec.describe Io, type: :model do
  context 'exchange rates' do
    it { expect(io.exchange_rate).to eq 1 }

    it 'in invalid when missing exchange rate' do
      io = build :io, curr_cd: 'GBP', company: company

      expect(io).not_to be_valid

      expect(io.errors.full_messages.first).to include 'Curr cd does not have an exchange rate for GBP'
    end

    it 'is valid when has an exchange rate' do
      exchange_rate
      io(opts: {curr_cd: 'GBP'})

      expect(io).to be_valid

      expect(io.exchange_rate).to eql 1.5
    end
  end


  def io(opts: {})
    defaults = {
      company: company
    }
    @io ||= create :io, defaults.merge(opts)
  end

  def company
    @company ||= create :company
  end

  def exchange_rate
    @exchange_rate ||= create :exchange_rate, {
      start_date: Date.today - 1.month,
      end_date: Date.today + 1.month,
      currency: (create :currency, curr_cd: 'GBP'),
      company: company,
      rate: 1.5
    }
  end
end
