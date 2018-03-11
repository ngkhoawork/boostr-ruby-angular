require 'rails_helper'

describe DisplayLineItemCsv do
  let!(:company) { create :company, :fast_create_company }

  context 'validations' do
    subject { line_item_csv }

    before do
      exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
    end

    it { is_expected.to validate_presence_of(:company_id) }
    it { is_expected.to validate_presence_of(:line_number) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:product_name) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:budget) }

    it { is_expected.to validate_numericality_of(:line_number) }
    it { is_expected.to validate_numericality_of(:quantity) }
    it { is_expected.to validate_numericality_of(:budget) }
    it { is_expected.to validate_numericality_of(:budget_delivered) }
    it { is_expected.to validate_numericality_of(:quantity_delivered) }
    it { is_expected.to validate_numericality_of(:quantity_delivered_3p) }

    it { is_expected.to allow_value("", nil).for(:quantity_delivered) }
    it { is_expected.to allow_value("", nil).for(:quantity_delivered_3p) }
  end

  context 'custom validations' do

    context 'multicurrency' do
      it 'is valid if io has exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
        io(curr_cd: 'BRL')
        line_item_csv(external_io_number: io.external_io_number)
        expect(line_item_csv).to be_valid
      end

      it 'is valid if temp_io has exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
        temp_io(curr_cd: 'BRL')
        line_item_csv(external_io_number: temp_io.external_io_number)
        expect(line_item_csv).to be_valid
      end

      it 'fails if io has no exchange rate' do
        exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
        io(curr_cd: 'BRL')
        exchange_rate.destroy
        line_item_csv(external_io_number: io.external_io_number)
        expect(line_item_csv).not_to be_valid
        expect(line_item_csv.errors.full_messages).to eql(["Budget has no exchange rate for BRL found at #{io.created_at.strftime("%m/%d/%Y")}"])
      end

      it 'fails if temp_io has no exchange_rate' do
        exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
        temp_io(curr_cd: 'BRL')
        exchange_rate.destroy
        line_item_csv(external_io_number: temp_io.external_io_number)
        expect(line_item_csv).not_to be_valid
        expect(line_item_csv.errors.full_messages).to eql(["Budget has no exchange rate for BRL found at #{temp_io.created_at.strftime("%m/%d/%Y")}"])
      end
    end

    context 'date parse error' do
      it 'validates that date can be parsed' do
        line_item_csv(external_io_number: io.external_io_number, start_date: '2017-11-11')
        expect(line_item_csv).to be_valid
      end

      it 'rejects inavlid start date' do
        line_item_csv(external_io_number: io.external_io_number, start_date: '43-34-1424')
        expect(line_item_csv).not_to be_valid
        expect(line_item_csv.errors.full_messages).to eql(["Start date failed to be parsed correctly"])
      end

      it 'rejects inavlid end date' do
        line_item_csv(external_io_number: io.external_io_number, end_date: '43-34-1424')
        expect(line_item_csv).not_to be_valid
        expect(line_item_csv.errors.full_messages).to eql(["End date failed to be parsed correctly"])
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

  it 'sets start date in American format' do
    line_item_csv(external_io_number: io.external_io_number, start_date: '12/15/2017')
    line_item_csv.perform
    expect(DisplayLineItem.last.start_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets start date in YY format' do
    line_item_csv(external_io_number: io.external_io_number, start_date: '12/15/17')
    line_item_csv.perform
    expect(DisplayLineItem.last.start_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets end date' do
    line_item_csv(external_io_number: io.external_io_number, end_date: '2017-12-15')
    line_item_csv.perform
    expect(DisplayLineItem.last.end_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets end date in American format' do
    line_item_csv(external_io_number: io.external_io_number, end_date: '12/15/2017')
    line_item_csv.perform
    expect(DisplayLineItem.last.end_date).to eql Date.new(2017, 12, 15)
  end

  it 'sets start date in YY format' do
    line_item_csv(external_io_number: io.external_io_number, end_date: '12/15/17')
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

  it 'sets quantity_remaining to quantity if quantity_delivered is empty' do
    line_item_csv(external_io_number: io.external_io_number, quantity: '10000', quantity_delivered: nil)
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity_remaining).to eql 10000
  end

  it 'sets quantity_delivered_3p' do
    line_item_csv(external_io_number: io.external_io_number, quantity_delivered_3p: '10000')
    line_item_csv.perform
    expect(DisplayLineItem.last.quantity_delivered_3p).to eql 10000
  end

  it 'sets ad_server_product' do
    line_item_csv(external_io_number: io.external_io_number, product_name: 'More Ads')
    line_item_csv.perform
    expect(DisplayLineItem.last.ad_server_product).to eql 'More Ads'
  end

  it 'does not match missing product' do
    line_item_csv(external_io_number: io.external_io_number, product_name: 'More Ads')
    line_item_csv.perform
    expect(DisplayLineItem.last.product).to be nil
  end

  it 'matches display product from deal' do
    product = create :product, revenue_type: 'Display', name: 'WoW'
    create :deal_product, deal: io.deal, product: product
    line_item_csv(external_io_number: io.external_io_number, product_name: 'More Ads')
    line_item_csv.perform
    expect(DisplayLineItem.last.product).to eql product
  end

  it 'sets ctr' do
    line_item_csv(external_io_number: io.external_io_number, ctr: 0.51)
    line_item_csv.perform
    expect(DisplayLineItem.last.ctr).to eql 0.51
  end

  it 'sets clicks' do
    line_item_csv(external_io_number: io.external_io_number, clicks: 951)
    line_item_csv.perform
    expect(DisplayLineItem.last.clicks).to eql 951
  end

  context 'multicurrency Io' do
    it 'sets local currency values according to exchange rate' do
      exchange_rate(currency: currency(curr_cd: 'BRL'), rate: 1.5)
      io(curr_cd: 'BRL')
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
    defaults = { start_date: Date.new(2017, 1, 1), end_date: Date.new(2017, 12, 31) }
    @_io ||= create :io, defaults.merge(opts)
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
    @_currency ||= Currency.find_by(opts) || create(:currency, opts)
  end

  def line_item_csv(opts={})
    opts[:company_id] = company.id
    defaults = { start_date: '2017-01-02', end_date: '2017-11-30' }
    @_line_item_csv ||= build :display_line_item_csv, defaults.merge(opts)
  end

  def exchange_rate(opts={})
    opts[:company_id] = company.id
    @_exchange_rate ||= create :exchange_rate, opts
  end
end
