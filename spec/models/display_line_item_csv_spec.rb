require 'rails_helper'

RSpec.describe DisplayLineItemCsv, type: :model do
  it { should validate_presence_of(:line_number) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:product_name) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:company_id) }

  it { should validate_numericality_of(:line_number) }
  it { should validate_numericality_of(:quantity) }
  it { should validate_numericality_of(:budget) }
  it { should validate_numericality_of(:budget_delivered) }
  it { should validate_numericality_of(:quantity_delivered) }
  it { should validate_numericality_of(:quantity_delivered_3p) }

  context 'custom validations' do
    # context 'product validation' do
    #   it 'is valid if product exists' do
    #     line_item_csv(external_io_number: io.external_io_number, product_name: product.name)
    #     expect(line_item_csv.valid?).to be true
    #   end

    #   it 'is invalid if product does not exist' do
    #     line_item_csv(external_io_number: io.external_io_number, product_name: 'La-La-Land')
    #     binding.pry
    #     expect(line_item_csv.valid?).to be false
    #   end
    # end
    context 'io or temp_io presence' do
      it 'validates io presence' do
        line_item_csv(external_io_number: io.external_io_number)
        expect(line_item_csv.valid?).to be true
      end

      it 'validates temp_io presence' do
        line_item_csv(external_io_number: temp_io.external_io_number)
        expect(line_item_csv.valid?).to be true
      end

      it 'fails if io and temp_io are not found via external_number' do
        line_item_csv(external_io_number: 123)
        expect(line_item_csv.valid?).to be false
        expect(line_item_csv.errors.full_messages).to eql(["Io or TempIo not found"])
      end
    end

    context 'multicurrency' do
      it 'is valid if io has exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'GBP'), rate: 1.5)
        io(curr_cd: 'GBP')
        line_item_csv(external_io_number: io.external_io_number)
        expect(line_item_csv.valid?).to be true
      end

      it 'is valid if temp_io has exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'GBP'), rate: 1.5)
        temp_io(curr_cd: 'GBP')
        line_item_csv(external_io_number: temp_io.external_io_number)
        expect(line_item_csv.valid?).to be true
      end

      it 'fails if io has no exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'GBP'), rate: 1.5)
        io(curr_cd: 'GBP')
        exchange_rate.destroy
        line_item_csv(external_io_number: io.external_io_number)
        expect(line_item_csv.valid?).to be false
        expect(line_item_csv.errors.full_messages).to eql(["Budget has no exchange rate for GBP found at #{io.created_at.strftime("%m/%d/%Y")}"])
      end

      it 'fails if temp_io has no exchange_rate' do
        exchange_rate(currency: currency(curr_cd: 'GBP'), rate: 1.5)
        temp_io(curr_cd: 'GBP')
        exchange_rate.destroy
        line_item_csv(external_io_number: temp_io.external_io_number)
        expect(line_item_csv.valid?).to be false
        expect(line_item_csv.errors.full_messages).to eql(["Budget has no exchange rate for GBP found at #{temp_io.created_at.strftime("%m/%d/%Y")}"])
      end
    end
  end

  it 'finds IO by external_io_number' do
    line_item_csv(external_io_number: io.external_io_number)
    line_item_csv.perform
    expect(io.reload.display_line_items.count).to be 1
  end

  it 'finds temp_io by external_io_number' do
    line_item_csv(external_io_number: temp_io.external_io_number)
    line_item_csv.perform
    expect(temp_io.reload.display_line_items.count).to be 1
  end

  it 'createw new display line item' do
    line_item_csv(external_io_number: io.external_io_number, line_number: 500)
    line_item_csv.perform
    expect(DisplayLineItem.last.line_number).to be 500
  end

  it 'updates existing line item' do
    display_line_item(io_id: io.id, budget: 1000)
    line_item_csv(external_io_number: io.external_io_number, line_number: display_line_item.line_number, budget: 2000)
    line_item_csv.perform
    expect(display_line_item.reload.budget).to eq 2000
  end

  it 'sets ad server' do
    line_item_csv(external_io_number: io.external_io_number, ad_server: 'DFP01')
    line_item_csv.perform
    expect(DisplayLineItem.last.ad_server).to eql 'DFP01'
  end

  it 'sets start date' do
    line_item_csv(external_io_number: io.external_io_number, start_date: '2017-12-15')
    line_item_csv.perform
    expect(DisplayLineItem.last.start_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets end date' do
    line_item_csv(external_io_number: io.external_io_number, end_date: '2017-12-15')
    line_item_csv.perform
    expect(DisplayLineItem.last.end_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets product' do
    line_item_csv(external_io_number: io.external_io_number, product_name: product.name)
    line_item_csv.perform
    expect(DisplayLineItem.last.product).to eql product
  end

  it 'sets quantity' do
    line_item_csv(external_io_number: io.external_io_number, quantity: 150)
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity).to be 150
  end

  it 'sets price' do
    line_item_csv(external_io_number: io.external_io_number, price: '0.99')
    line_item_csv.perform
    expect(DisplayLineItem.last.price).to eql 0.99
  end

  it 'sets pricing_type' do
    line_item_csv(external_io_number: io.external_io_number, pricing_type: 'CPS')
    line_item_csv.perform
    expect(DisplayLineItem.last.pricing_type).to eql 'CPS'
  end

  it 'sets budget' do
    line_item_csv(external_io_number: io.external_io_number, budget: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget).to eql 10000
  end

  it 'sets budget_loc' do
    line_item_csv(external_io_number: io.external_io_number, budget: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget_loc).to eql 10000
  end

  it 'sets budget_delivered' do
    line_item_csv(external_io_number: io.external_io_number, budget_delivered: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget_delivered).to eql 10000
  end

  it 'sets budget_delivered_loc' do
    line_item_csv(external_io_number: io.external_io_number, budget_delivered: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget_delivered_loc).to eql 10000
  end

  it 'sets budget_remaining' do
    line_item_csv(external_io_number: io.external_io_number, budget: '10000', budget_delivered: '5000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget_remaining).to eql 5000
  end

  it 'sets budget_remaining_loc' do
    line_item_csv(external_io_number: io.external_io_number, budget: '10000', budget_delivered: '5000')
    line_item_csv.perform
    expect(DisplayLineItem.last.budget_remaining_loc).to eql 5000
  end

  it 'sets quantity_delivered' do
    line_item_csv(external_io_number: io.external_io_number, quantity_delivered: '150')
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity_delivered).to eql 150
  end

  it 'sets quantity_remaining' do
    line_item_csv(external_io_number: io.external_io_number, quantity: '10000', quantity_delivered: '150')
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity_remaining).to eql 9850
  end

  it 'sets quantity_delivered_3p' do
    line_item_csv(external_io_number: io.external_io_number, quantity_delivered_3p: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity_delivered_3p).to eql 10000
  end

  context 'multicurrency Io' do
    it 'sets local currency values according to exchange rate' do
      exchange_rate(currency: currency(curr_cd: 'GBP'), rate: 1.5)
      io(curr_cd: 'GBP')
      line_item_csv(
        external_io_number: io.external_io_number,
        budget: '10000',
        budget_delivered: '9000'
      ).perform
      dli = DisplayLineItem.last
      expect(dli.budget).to eql 6666.67
      expect(dli.budget_loc).to eql 10000
      expect(dli.budget_delivered).to eql 6000
      expect(dli.budget_delivered_loc).to eql 9000
      expect(dli.budget_remaining).to eql 666.67
      expect(dli.budget_remaining_loc).to eql 1000
    end
  end

  def display_line_item(opts={})
    @_display_line_item ||= create :display_line_item, opts
  end

  def io(opts={})
    opts[:company_id] = company.id
    @_io ||= create :io, opts
  end

  def temp_io(opts={})
    opts[:company_id] = company.id
    @_temp_io ||= create :temp_io, opts
  end

  def company(opts={})
    @_company ||= create :company, opts
  end

  def product
    @_product ||= create :product, company: company
  end

  def currency(opts={})
    @_currency ||= create :currency, opts
  end

  def line_item_csv(opts={})
    opts[:company_id] = company.id
    @_line_item_csv ||= build :display_line_item_csv, opts
  end

  def exchange_rate(opts={})
    opts[:company_id] = company.id
    @_exchange_rate ||= create :exchange_rate, opts
  end
end
