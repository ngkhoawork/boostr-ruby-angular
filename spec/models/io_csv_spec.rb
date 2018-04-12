require 'rails_helper'

RSpec.describe IoCsv, type: :model do
  it { should validate_presence_of(:io_external_number) }
  it { should validate_presence_of(:io_name) }
  it { should validate_presence_of(:io_start_date) }
  it { should validate_presence_of(:io_end_date) }
  it { should validate_presence_of(:io_budget) }
  it { should validate_presence_of(:io_curr_cd) }
  it { should validate_presence_of(:io_advertiser) }
  it { should validate_presence_of(:company_id) }

  it { should validate_numericality_of(:io_external_number) }
  it { should validate_numericality_of(:io_budget) }

  context 'custom validations' do
    context 'date parse error' do
      it 'validates that date can be parsed' do
        io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26')
        expect(io_csv).to be_valid
      end

      it 'rejects inavlid start date' do
        io_csv(io_external_number: io.external_io_number, io_start_date: 'test')
        expect(io_csv).not_to be_valid
        expect(io_csv.errors.full_messages).to eql(["Io start date failed to be parsed correctly"])
      end

      it 'rejects inavlid end date' do
        io_csv(io_external_number: io.external_io_number, io_end_date: '43-34-1424')
        expect(io_csv).not_to be_valid
        expect(io_csv.errors.full_messages).to eql(["Io end date failed to be parsed correctly"])
      end
    end
  end

  context 'auto-close io_number deal' do
    before(:each) do
      closed_stage
    end

    context 'auto-close enabled' do
      it 'closes the deal ID received as IO number' do
        io_csv(io_external_number: 8989, io_name: "EVE Mattress - Performance Test - March 2017_#{deal.id}", auto_close_deals: true).perform
        expect(deal.reload.stage).to eq closed_stage
      end

      it 'maps the incoming order to the freshly generated IO' do
        io_csv(io_external_number: 8989, io_name: "EVE Mattress - Performance Test - March 2017_#{deal.id}", auto_close_deals: true).perform
        expect(deal.io.name).to eq deal.name
        expect(deal.io.io_number).to eq deal.id
        expect(deal.io.external_io_number).to eq 8989
      end
    end

    context 'auto-close disabled' do
      it 'leaves deal open' do
        deal(stage: discuss_stage)
        io_csv(io_external_number: 8989, io_name: "EVE Mattress - Performance Test - March 2017_#{deal.id}", auto_close_deals: false).perform
        expect(deal.reload.stage).to eq discuss_stage
      end
    end
  end

  context 'IO is found' do
    it 'matches via io_number and updates external_io_number' do
      io_csv(io_external_number: 123, io_name: "Test_Order_#{io.io_number}").perform
      expect(io.reload.external_io_number).to be 123
    end

    it 'updates IO order start date' do
      io(start_date: '2017-02-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26').perform
      expect(io.reload.start_date).to eql Date.new(2017,01,26)
    end

    it 'does not update start date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26').perform
      expect(io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'updates IO order end date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_end_date: '2017-01-26').perform
      expect(io.reload.end_date).to eql Date.new(2017,01,26)
    end

    it 'does not update end date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      io_csv(io_external_number: io.external_io_number, io_end_date: '2017-01-26').perform
      expect(io.reload.end_date).to eql Date.new(2017,03,01)
    end

    it 'sets exchange rate' do
      io(start_date: '2017-02-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26', exchange_rate: '1.55').perform

      expect(io.reload.exchange_rate).to eql 1.55
    end
  end

  context 'IO is not found and TempIO is used instead' do
    context 'TempIO does not exist' do
      it 'creates a new TempIO' do
        expect {
          io_csv(io_external_number: 123).perform
        }.to change(TempIo, :count).by 1
      end

      it 'sets temp_io external_io_number' do
        io_csv(io_external_number: 123).perform
        expect(TempIo.last.external_io_number).to be 123
      end

      it 'sets exchange rate' do
        io_csv(io_external_number: 123, exchange_rate: '1.55').perform

        expect(TempIo.last.exchange_rate).to eql 1.55
      end
    end

    context 'TempIO exists' do
      it 'finds existing TempIO' do
        temp_io
        expect {
          io_csv(io_external_number: temp_io.external_io_number).perform
        }.not_to change(TempIo, :count)
      end
    end

    it 'sets temp_io name' do
      io_csv(io_external_number: temp_io.external_io_number, io_name: 'Stest_321').perform
      expect(temp_io.reload.name).to eql 'Stest_321'
    end

    it 'sets temp_io start_date' do
      io_csv(io_external_number: temp_io.external_io_number, io_start_date: '2017-01-01').perform
      expect(temp_io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'sets start date in American format' do
      io_csv(io_external_number: temp_io.external_io_number, io_start_date: '12/15/2017').perform
      expect(temp_io.reload.start_date).to eql Date.new(2017, 12, 15)
    end

    it 'sets start date in YY format' do
      io_csv(io_external_number: temp_io.external_io_number, io_start_date: '12/15/17').perform
      expect(temp_io.reload.start_date).to eql Date.new(2017, 12, 15)
    end

    it 'sets temp_io end_date' do
      io_csv(io_external_number: temp_io.external_io_number, io_end_date: '2017-01-01').perform
      expect(temp_io.reload.end_date).to eql Date.new(2017,01,01)
    end

    it 'sets end date in American format' do
      io_csv(io_external_number: temp_io.external_io_number, io_end_date: '12/15/2017').perform
      expect(temp_io.reload.end_date).to eql Date.new(2017, 12, 15)
    end

    it 'sets start date in YY format' do
      io_csv(io_external_number: temp_io.external_io_number, io_end_date: '12/15/17').perform
      expect(temp_io.reload.end_date).to eql Date.new(2017, 12, 15)
    end

    it 'sets temp_io advertiser name' do
      io_csv(io_external_number: temp_io.external_io_number, io_advertiser: 'Test').perform
      expect(temp_io.reload.advertiser).to eql 'Test'
    end

    it 'sets temp_io agency name' do
      io_csv(io_external_number: temp_io.external_io_number, io_agency: 'Test').perform
      expect(temp_io.reload.agency).to eql 'Test'
    end

    it 'sets temp_io budget' do
      io_csv(io_external_number: temp_io.external_io_number, io_budget: 450000.00).perform
      expect(temp_io.reload.budget).to eql 450000.00
    end

    it 'sets temp_io budget_loc' do
      io_csv(io_external_number: temp_io.external_io_number, io_budget_loc: 450000.00).perform
      expect(temp_io.reload.budget_loc).to eql 450000.00
    end

    it 'sets temp_io currency code' do
      gbp_currency
      io_csv(io_external_number: temp_io.external_io_number, io_curr_cd: 'GBP').perform

      expect(TempIo.last.curr_cd).to eql 'GBP'
    end

    it 'sets exchange rate' do
      io_csv(io_external_number: temp_io.external_io_number, exchange_rate: '1.55').perform

      expect(TempIo.last.exchange_rate).to eql 1.55
    end
  end

  def gbp_currency
    @_gbp_currency ||=
      Currency.find_or_create_by(curr_cd: 'GBP', curr_symbol: '£', name: 'Great Britain Pound').tap do |currency|
        currency.exchange_rates << build(:exchange_rate, company: company, rate: 1.5, currency: currency)
      end
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
  end

  def discuss_stage
    @_discuss_stage ||= create :discuss_stage, company_id: company.id
  end

  def closed_stage
    @_closed_stage ||= create :closed_won_stage, company_id: company.id
  end

  def io(opts={})
    opts[:company_id] = company.id
    @_io ||= create :io, opts
  end

  def temp_io(opts={})
    opts[:company_id] = company.id
    @_temp_io ||= create :temp_io, opts
  end

  def io_csv(opts={})
    opts[:company_id] = company.id
    @_io_csv ||= build :io_csv, opts
  end

  def company(opts={})
    @_company ||= create :company
  end
end
