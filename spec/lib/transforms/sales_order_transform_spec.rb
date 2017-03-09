require 'rails_helper'
require 'pp'

RSpec.describe Transforms::SalesOrderTransform, transforms: true do
  let(:company) { create :company }
  # subject(:subject) { Transforms::SalesOrderTransform.new(csv_source, headers: true) }
  # let(:csv_source) { File.new("#{Rails.root}/spec/support/sales_order_example.csv") }

  context 'IO is found' do
    it 'matches via io_number and updates external_io_number' do
      subject(csv_source sales_order_id: 123, sales_order_name: "Test_Order_#{io.io_number}")
      expect(io.reload.external_io_number).to be 123
    end

    it 'updates IO order start date' do
      io(start_date: '2017-02-01', end_date: '2017-03-01')
      subject(csv_source sales_order_id: io.external_io_number, order_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,26)
    end

    it 'does not update start date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      subject(csv_source sales_order_id: io.external_io_number, order_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'does not update start date if order_start_date is later than IO start date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      subject(csv_source sales_order_id: io.external_io_number, order_start_date: '2017-01-26')
      expect(io.reload.start_date).to eql Date.new(2017,01,01)
    end

    it 'updates IO order end date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      subject(csv_source sales_order_id: io.external_io_number, order_end_date: '2017-01-26')
      expect(io.reload.end_date).to eql Date.new(2017,01,26)
    end

    it 'does not update end date if IO has content_fees' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      create_list :content_fee, 3, io: io
      subject(csv_source sales_order_id: io.external_io_number, order_end_date: '2017-01-26')
      expect(io.reload.end_date).to eql Date.new(2017,03,01)
    end

    it 'does not update end date if order_end_date is later than IO end date' do
      io(start_date: '2017-01-01', end_date: '2017-03-01')
      subject(csv_source sales_order_id: io.external_io_number, order_end_date: '2017-03-02')
      expect(io.reload.end_date).to eql Date.new(2017,03,01)
    end    
  end

  context 'IO is not found' do
    context 'TempIO does not exist' do
      it 'creates a new TempIO' do
        expect { 
          subject(csv_source sales_order_id: 123)
        }.to change(TempIo, :count).by 1
      end

      it 'sets temp_io external_io_number' do
        subject(csv_source sales_order_id: 123)
        expect(TempIo.last.external_io_number).to be 123
      end

      it 'sets temp_io name' do
        subject(csv_source sales_order_id: 123, sales_order_name: 'Stest_321')
        expect(TempIo.last.name).to eql 'Stest_321'
      end

      it 'sets temp_io start_date' do
        subject(csv_source sales_order_id: 123, order_start_date: '2017-01-01')
        expect(TempIo.last.start_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io end_date' do
        subject(csv_source sales_order_id: 123, order_end_date: '2017-01-01')
        expect(TempIo.last.end_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io advertiser name' do
        subject(csv_source sales_order_id: 123, advertiser_name: 'Test')
        expect(TempIo.last.advertiser).to eql 'Test'
      end

      it 'sets temp_io agency name' do
        subject(csv_source sales_order_id: 123, agency_name: 'Test')
        expect(TempIo.last.agency).to eql 'Test'
      end

      it 'sets temp_io budget' do
        subject(csv_source sales_order_id: 123, total_order_value: 450000.00)
        expect(TempIo.last.budget).to eql 450000.00
      end

      it 'sets temp_io budget_loc' do
        subject(csv_source sales_order_id: 123, total_order_value: 450000.00)
        expect(TempIo.last.budget_loc).to eql 450000.00
      end

      it 'sets temp_io currency code' do
        subject(csv_source sales_order_id: 123, order_currency_id: 'GBP')
        expect(TempIo.last.curr_cd).to eql 'GBP'
      end
    end

    context 'TempIO exists' do
      it 'finds existing TempIO' do
        temp_io
        expect { 
          subject(csv_source sales_order_id: temp_io.external_io_number)
        }.not_to change(TempIo, :count)
      end

      it 'sets temp_io name' do
        subject(csv_source sales_order_id: temp_io.external_io_number, sales_order_name: 'Stest_321')
        expect(temp_io.reload.name).to eql 'Stest_321'
      end

      it 'sets temp_io start_date' do
        subject(csv_source sales_order_id: temp_io.external_io_number, order_start_date: '2017-01-01')
        expect(temp_io.reload.start_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io end_date' do
        subject(csv_source sales_order_id: temp_io.external_io_number, order_end_date: '2017-01-01')
        expect(temp_io.reload.end_date).to eql Date.new(2017,01,01)
      end

      it 'sets temp_io advertiser name' do
        subject(csv_source sales_order_id: temp_io.external_io_number, advertiser_name: 'Test')
        expect(temp_io.reload.advertiser).to eql 'Test'
      end

      it 'sets temp_io agency name' do
        subject(csv_source sales_order_id: temp_io.external_io_number, agency_name: 'Test')
        expect(temp_io.reload.agency).to eql 'Test'
      end

      it 'sets temp_io budget' do
        subject(csv_source sales_order_id: temp_io.external_io_number, total_order_value: 450000.00)
        expect(temp_io.reload.budget).to eql 450000.00
      end

      it 'sets temp_io budget_loc' do
        subject(csv_source sales_order_id: temp_io.external_io_number, total_order_value: 450000.00)
        expect(temp_io.reload.budget_loc).to eql 450000.00
      end

      it 'sets temp_io currency code' do
        subject(csv_source sales_order_id: temp_io.external_io_number, order_currency_id: 'GBP')
        expect(temp_io.reload.curr_cd).to eql 'GBP'
      end
    end
  end

# 2017-01-26,2017-02-05
  # xit 'updates IO advertiser' do
  #   subject(csv_source sales_order_id: io.external_io_number)
  #   expect(io.advertiser.name).to eql(csv_source[:advertiser_name])
  # end

  def io(opts={})
    @_io ||= create :io, opts
  end

  def temp_io(opts={})
    @_temp_io ||= create :temp_io, opts
  end

  def csv_source(opts={})
    @_csv_source ||= build :sales_order_csv_data, opts
  end

  def subject(csv_source)
    @_subject ||= Transforms::SalesOrderTransform.new(generate_csv(csv_source)).transform
  end
end
