require 'rails_helper'

describe DisplayLineItemBudget, type: :model do
  context 'after_create' do
    it 'updates display line item delivered and remaining budgets' do
      expect(display_item.budget_delivered.to_f).to be 3000.0
      expect(display_item.budget_delivered_loc.to_f).to be 3000.0
      expect(display_item.budget_remaining.to_f).to be 2000.0
      expect(display_item.budget_remaining_loc.to_f).to be 2000.0

      budget_item
      display_item.reload

      expect(display_item.reload.budget_delivered.to_f).to be 500.0
      expect(display_item.reload.budget_delivered_loc.to_f).to be 500.0
      expect(display_item.reload.budget_remaining.to_f).to be 4500.0
      expect(display_item.reload.budget_remaining_loc.to_f).to be 4500.0
    end
  end

  context 'after_update' do
    it 'updates display line item delivered and remaining budgets' do
      budget_item.update(budget: 1000, budget_loc: 1000)
      display_item.reload

      expect(display_item.budget_delivered.to_f).to be 1000.0
      expect(display_item.budget_delivered_loc.to_f).to be 1000.0
      expect(display_item.budget_remaining.to_f).to be 4000.0
      expect(display_item.budget_remaining_loc.to_f).to be 4000.0
    end
  end

  context 'after_destroy' do
    it 'updates display line item delivered and remaining budgets' do
      budget_item.destroy
      display_item.reload

      expect(display_item.budget_delivered.to_f).to be 0.0
      expect(display_item.budget_delivered_loc.to_f).to be 0.0
      expect(display_item.budget_remaining.to_f).to be 5000.0
      expect(display_item.budget_remaining_loc.to_f).to be 5000.0
    end
  end

  private

  def company
    create :company
  end

  def display_item
    @_display_item ||= create :display_line_item, budget: 5000.0,
                                                  budget_loc: 5000.0,
                                                  budget_delivered: 3000.0,
                                                  budget_delivered_loc: 3000.0,
                                                  io: io,
                                                  start_date: start_date,
                                                  end_date: end_date
  end

  def io
    create :io, company: company, start_date: start_date, end_date: end_date
  end

  def budget_item
    create :display_line_item_budget, display_line_item: display_item,
                                                        budget: 500,
                                                        budget_loc: 500,
                                                        start_date: DateTime.parse('2018-01-01'),
                                                        end_date: DateTime.parse('2018-01-31')
  end

  def start_date
    @_start_date ||= DateTime.parse('2018-01-01')
  end

  def end_date
    @_end_date ||= DateTime.parse('2018-03-31')
  end
end
