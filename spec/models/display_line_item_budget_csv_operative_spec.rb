require 'rails_helper'

RSpec.describe DisplayLineItemBudgetCsvOperative, type: :model do
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:line_number) }
  it { should validate_presence_of(:month_and_year) }
  it { should validate_presence_of(:budget_loc) }

  it { should_not validate_presence_of(:impressions) }

  describe 'object lookup' do
    it 'finds line item budget via start date' do
      display_line_item_budget(quantity: 5000, start_date: Date.new(2018,1,1), end_date: Date.new(2018,1,31))

      csv_object(month_and_year: '01-2018', impressions: 10000).perform

      expect(display_line_item_budget.reload.quantity).to be 10000
    end

    it 'finds line item budget via invoice_id' do
      display_line_item_budget(invoice_id: 9999, quantity: 5000)

      csv_object(invoice_id: '9999', impressions: 10000).perform

      expect(display_line_item_budget.reload.quantity).to be 10000
    end
  end

  def company(opts={})
    @_company ||= create :company
  end

  def subject(opts={})
    defaults = {
      company_id: company.id
    }
    @_subject ||= build :display_line_item_budget_csv_operative, defaults.merge(opts)
  end

  def display_line_item_budget(opts={})
    defaults = {
      display_line_item: display_line_item
    }

    @display_line_item_budget ||= create :display_line_item_budget, defaults.merge(opts)
  end

  def csv_object(opts={})
    defaults = {
      company_id: display_line_item.io.company_id,
      line_number: display_line_item.line_number
    }

    @csv_object ||= build :display_line_item_budget_csv_operative, defaults.merge(opts)
  end

  def display_line_item
    @display_line_item ||= create :display_line_item, io: io
  end

  def io
    @io ||= create :io, company: company
  end

  def company
    @company ||= create :company
  end
end
