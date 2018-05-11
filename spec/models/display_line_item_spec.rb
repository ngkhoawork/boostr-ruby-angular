require 'rails_helper'

RSpec.describe DisplayLineItem, type: :model do
  it 'closes deal display product when line item comes from datafeed' do
    deal_product

    deal.update(stage: closed_won_stage, updated_by: 0)

    expect(deal_product.reload.open).to be true

    create :display_line_item, io: deal.io, dont_update_parent_budget: true

    expect(deal_product.reload.open).to be false
  end

  describe '#remove_budgets_out_of_dates' do
    it 'removes lines outside of flight dates on date change' do
      display_line_item(start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 4, 30))

      display_line_item_budgets(4, start_date: Date.new(2018, 2, 1), end_date: Date.new(2018, 2, 28))
      display_line_item_budgets.last.update(start_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 4, 30))
      display_line_item_budgets.first.update(start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 1, 31))

      expect(display_line_item.display_line_item_budgets.count).to be 4

      display_line_item.update(start_date: Date.new(2018, 2, 1), end_date: Date.new(2018, 3, 31))

      expect(display_line_item.display_line_item_budgets.count).to be 2
    end

    it 'does not remove line item budgets if no date change' do
      display_line_item(start_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 4, 30))

      display_line_item_budgets(4, start_date: Date.new(2016, 1, 1), end_date: Date.new(2016, 1, 31))

      expect(display_line_item.display_line_item_budgets.count).to be 4

      display_line_item.update(start_date: Date.new(2018, 1, 1))

      expect(display_line_item.display_line_item_budgets.count).to be 4
    end
  end

  def company
    @company ||= create :company
  end

  def deal
    @deal ||= create :deal, company: company
  end

  def closed_won_stage
    @_won_stage ||= create(:won_stage, company: company, open: false)
  end

  def display_product
    @display_product ||= create(:product, revenue_type: 'Display', company: company)
  end

  def deal_product
    @deal_product ||= create :deal_product, deal: deal, product: display_product
  end

  def display_line_item(opts={})
    defaults = {
      io: deal.io
    }

    @display_line_item ||= create :display_line_item, defaults.merge(opts)
  end

  def display_line_item_budgets(count=1, opts={})
    defaults = {
      display_line_item: display_line_item
    }

    @display_line_item_budgets ||= create_list :display_line_item_budget, count, defaults.merge(opts)
  end
end
