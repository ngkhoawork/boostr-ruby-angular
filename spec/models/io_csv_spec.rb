require 'rails_helper'

RSpec.describe IoCsv, type: :model do
  it { should validate_presence_of(:io_external_number) }
  it { should validate_presence_of(:io_start_date) }
  it { should validate_presence_of(:io_end_date) }
  it { should validate_presence_of(:io_budget) }
  it { should validate_presence_of(:io_curr_cd) }
  it { should validate_presence_of(:io_advertiser) }
  it { should validate_presence_of(:company_id) }

  it { should validate_numericality_of(:io_external_number) }
  it { should validate_numericality_of(:io_budget) }

  context 'IO is found' do
    it 'matches via io_number and updates external_io_number' do
      io_csv(io_external_number: 123, io_name: "Test_Order_#{io.io_number}")
      expect(io.reload.external_io_number).to be 123
    end

    it 'updates IO order start date' do
      io(start_date: '2017-02-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,26)
    end

    it 'does not update start date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'does not update start date if io_start_date is later than IO start date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'updates IO order end date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_end_date: '2017-01-26')
      expect(io.reload.end_date).to eql Date.new(2017,01,26)
    end

    it 'does not update end date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      io_csv(io_external_number: io.external_io_number, io_end_date: '2017-01-26')
      expect(io.reload.end_date).to eql Date.new(2017,03,01)
    end

    it 'does not update end date if io_end_date is later than IO end date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      io_csv(io_external_number: io.external_io_number, io_end_date: '2017-03-02')
      expect(io.reload.end_date).to eql Date.new(2017,03,01)
    end
  end

  context 'IO is not found' do
    context 'TempIO does not exist' do
      it 'creates a new TempIO' do
        expect {
          io_csv(io_external_number: 123)
        }.to change(TempIo, :count).by 1
      end

      it 'sets temp_io external_io_number' do
        io_csv(io_external_number: 123)
        expect(TempIo.last.external_io_number).to be 123
      end

      it 'sets temp_io name' do
        io_csv(io_external_number: 123, io_name: 'Stest_321')
        expect(TempIo.last.name).to eql 'Stest_321'
      end

      it 'sets temp_io start_date' do
        io_csv(io_external_number: 123, io_start_date: '2017-01-01')
        expect(TempIo.last.start_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io end_date' do
        io_csv(io_external_number: 123, io_end_date: '2017-01-01')
        expect(TempIo.last.end_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io advertiser name' do
        io_csv(io_external_number: 123, io_advertiser: 'Test')
        expect(TempIo.last.advertiser).to eql 'Test'
      end

      it 'sets temp_io agency name' do
        io_csv(io_external_number: 123, io_agency: 'Test')
        expect(TempIo.last.agency).to eql 'Test'
      end

      it 'sets temp_io budget' do
        io_csv(io_external_number: 123, io_budget: 450000.00)
        expect(TempIo.last.budget).to eql 450000.00
      end

      it 'sets temp_io budget_loc' do
        io_csv(io_external_number: 123, io_budget_loc: 450000.00)
        expect(TempIo.last.budget_loc).to eql 450000.00
      end

      it 'sets temp_io currency code' do
        io_csv(io_external_number: 123, io_curr_cd: 'GBP')
        expect(TempIo.last.curr_cd).to eql 'GBP'
      end
    end

    context 'TempIO exists' do
      it 'finds existing TempIO' do
        temp_io
        expect {
          io_csv(io_external_number: temp_io.external_io_number)
        }.not_to change(TempIo, :count)
      end

      it 'sets temp_io name' do
        io_csv(io_external_number: temp_io.external_io_number, io_name: 'Stest_321')
        expect(temp_io.reload.name).to eql 'Stest_321'
      end

      it 'sets temp_io start_date' do
        io_csv(io_external_number: temp_io.external_io_number, io_start_date: '2017-01-01')
        expect(temp_io.reload.start_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io end_date' do
        io_csv(io_external_number: temp_io.external_io_number, io_end_date: '2017-01-01')
        expect(temp_io.reload.end_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io advertiser name' do
        io_csv(io_external_number: temp_io.external_io_number, io_advertiser: 'Test')
        expect(temp_io.reload.advertiser).to eql 'Test'
      end

      it 'sets temp_io agency name' do
        io_csv(io_external_number: temp_io.external_io_number, io_agency: 'Test')
        expect(temp_io.reload.agency).to eql 'Test'
      end

      it 'sets temp_io budget' do
        io_csv(io_external_number: temp_io.external_io_number, io_budget: 450000.00)
        expect(temp_io.reload.budget).to eql 450000.00
      end

      it 'sets temp_io budget_loc' do
        io_csv(io_external_number: temp_io.external_io_number, io_budget_loc: 450000.00)
        expect(temp_io.reload.budget_loc).to eql 450000.00
      end

      it 'sets temp_io currency code' do
        io_csv(io_external_number: temp_io.external_io_number, io_curr_cd: 'GBP')
        expect(temp_io.reload.curr_cd).to eql 'GBP'
      end
    end
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
    (build :io_csv, opts).perform
  end

  def company(opts={})
    @_company ||= create :company
  end
end
