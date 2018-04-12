require 'rails_helper'

RSpec.describe TempIo, type: :model do
  context 'exchange rates' do
    it { expect(temp_io.exchange_rate).to eq 1 }

    it 'in invalid when missing exchange rate' do
      temp_io = build :temp_io, curr_cd: 'GBP', company: company

      expect(temp_io).not_to be_valid

      expect(temp_io.errors.full_messages.first).to include 'Curr cd does not have an exchange rate for GBP'
    end

    it 'is valid when has an exchange rate' do
      exchange_rate
      temp_io(opts: {curr_cd: 'GBP'})

      expect(temp_io).to be_valid

      expect(temp_io.exchange_rate).to eql 1.5
    end
  end


  def temp_io(opts: {})
    defaults = {
      company: company
    }
    @temp_io ||= create :temp_io, defaults.merge(opts)
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
