require 'rails_helper'

RSpec.describe DisplayLineItem, type: :model do
  before do
    deal_product
    deal.update(stage: closed_won_stage, updated_by: 0)
  end

  context 'after_create' do
    it 'closes deal display product when line item comes from datafeed' do
      expect(deal_product.reload.open).to be true
      create :display_line_item, io: deal.io, dont_update_parent_budget: true
      expect(deal_product.reload.open).to be false
    end
  end

  context 'before_create' do
    describe '#correct_budget_remaining' do
      it 'corrects remaining budgets when create without budget_delivered' do
        expect(item.budget_delivered.to_f).to be 0.0
        expect(item.budget_delivered_loc.to_f).to be 0.0
        expect(item.budget_remaining.to_f).to be 5000.0
        expect(item.budget_remaining_loc.to_f).to be 5000.0
      end

      it 'corrects remaining budgets when create with budget_delivered' do
        expect(item_with_delivered.budget_delivered.to_f).to be 3000.0
        expect(item_with_delivered.budget_delivered_loc.to_f).to be 3000.0
        expect(item_with_delivered.budget_remaining.to_f).to be 2000.0
        expect(item_with_delivered.budget_remaining_loc.to_f).to be 2000.0
      end
    end

    describe '#set_alert' do
      it 'called set_alert when create without delivered' do
        expect(item.daily_run_rate.to_f).to be 0.0
        expect(item.daily_run_rate_loc.to_f).to be 0.0
        expect(item.num_days_til_out_of_budget.to_i).to be 0
        expect(item.balance.to_f).to be 0.0
        expect(item.balance_loc.to_f).to be 0.0
      end

      it 'called set_alert when create with delivered' do
        expect(item_with_delivered.daily_run_rate.to_f).to be 600.0
        expect(item_with_delivered.daily_run_rate_loc.to_f).to be 600.0
        expect(item_with_delivered.num_days_til_out_of_budget.to_i).to be 3
        expect(item_with_delivered.balance.to_f).to be 1800.0
        expect(item_with_delivered.balance_loc.to_f).to be 1800.0
      end
    end
  end

  context 'before_save' do
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
  end

  context 'before_update' do
    describe '#reset_budget_delivered' do
      it 'resets delivered and remaining budgets when update without override_budget_delivered' do
        item.update(
          budget_delivered: 1000.0,
          budget_delivered_loc: 1000.0
        )

        expect(item.budget_delivered.to_f).to be 0.0
        expect(item.budget_delivered_loc.to_f).to be 0.0
        expect(item.budget_remaining.to_f).to be 5000.0
        expect(item.budget_remaining_loc.to_f).to be 5000.0
      end
    end
    describe '#reset_budget_delivered' do
      it 'updates delivered and remaining budgets when update with override_budget_delivered' do
        item_with_delivered.update(
          budget_delivered: 1000.0,
          budget_delivered_loc: 1000.0,
          override_budget_delivered: true
        )

        expect(item_with_delivered.budget_delivered.to_f).to be 1000.0
        expect(item_with_delivered.budget_delivered_loc.to_f).to be 1000.0
        expect(item_with_delivered.budget_remaining.to_f).to be 4000.0
        expect(item_with_delivered.budget_remaining_loc.to_f).to be 4000.0
      end
    end
  end

  context 'after_save' do
    describe '#update_io_budget' do
      it 'updates io budget after create' do
        create :display_line_item, io: deal.io, budget: 50
        expect(deal.io.reload.budget.to_f).to be 50.0
      end
      it 'updates io budget after update' do
        display_item = create :display_line_item, io: deal.io, budget: 50
        expect(deal.io.reload.budget.to_f).to be 50.0
        display_item.update(budget: 100)
        expect(deal.io.reload.budget.to_f).to be 100.0
      end
    end
  end

  private

  def company
    @company ||= create :company
  end

  def deal
    @deal ||= create :deal, company: company
  end

  def io
    @_io ||= create :io, company: company
  end

  def item
    @_item ||= create :display_line_item, io: io,
                                          budget: 5000.0,
                                          budget_loc: 5000.0,
                                          start_date: start_date,
                                          end_date: end_date
  end

  def item_with_delivered
    @_item_with_delivered ||= create :display_line_item,  io: io,
                                                          budget: 5000.0,
                                                          budget_loc: 5000.0,
                                                          budget_delivered: 3000.0,
                                                          budget_delivered_loc: 3000.0,
                                                          start_date: start_date,
                                                          end_date: end_date
  end

  def start_date
    @_start_date ||= (DateTime.now - 4.days)
  end

  def end_date
    @_end_date ||= (DateTime.now + 5.days)
  end

  def closed_won_stage
    create :won_stage, company: company, open: false
  end

  def display_product
    create :product, revenue_type: 'Display', company: company
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
