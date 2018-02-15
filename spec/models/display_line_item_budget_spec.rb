require 'rails_helper'

describe DisplayLineItemBudget, type: :model do
  context 'custom validations' do
    context 'sum_of_budgets_less_than_line_item_budget' do
      before do
        display_line_item(budget_loc: 100_000)
        display_line_item_budget(
          budget_loc: 100_000,
          display_line_item_id: display_line_item.id
        )
      end

      it 'rejects new items that exceed total line item budget' do
        subject.assign_attributes(
          display_line_item_id: display_line_item.id,
          budget_loc: 10_000
        )

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to include(
          'Budget sum of monthly budgets can\'t be more then line item budget'
        )
      end

      it 'allows to exceed total line item budget if budget has dfp correction' do
        subject.assign_attributes(
          display_line_item_id: display_line_item.id,
          has_dfp_budget_correction: true,
          budget_loc: 10_000
        )

        expect(subject).to be_valid
      end

      context 'budget buffer' do
        it 'allows to exceed budget within 10 units' do
          subject.assign_attributes(
            display_line_item_id: display_line_item.id,
            budget_loc: 9.99
          )

          expect(subject).to be_valid

          subject.budget_loc = 10.00

          expect(subject).to be_valid
        end

        it 'rejects exceeding budget by more than 10 units' do
          subject.assign_attributes(
            display_line_item_id: display_line_item.id,
            budget_loc: 10.01
          )

          expect(subject).not_to be_valid
          expect(subject.errors.full_messages).to include(
            'Budget sum of monthly budgets can\'t be more then line item budget'
          )
        end
      end
    end

    context 'budget_less_than_display_line_item_budget' do
      before do
        display_line_item(budget_loc: 100_000)
      end

      it 'rejects new items that exceed total line item budget' do
        subject.assign_attributes(
          display_line_item_id: display_line_item.id,
          budget_loc: 200_000
        )

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to include(
          "Budget sum of monthly budgets can't be more then line item budget"
        )
      end

      it 'allows to exceed total line item budget if budget has dfp correction' do
        subject.assign_attributes(
          display_line_item_id: display_line_item.id,
          has_dfp_budget_correction: true,
          budget_loc: 200_000
        )

        expect(subject).to be_valid
      end

      context 'budget buffer' do
        it 'allows to exceed budget within 10 units' do
          subject.assign_attributes(
            display_line_item_id: display_line_item.id,
            budget_loc: 100_009.99
          )

          expect(subject).to be_valid

          subject.budget_loc = 100_010.00

          expect(subject).to be_valid
        end

        it 'rejects exceeding budget by more than 10 units' do
          subject.assign_attributes(
            display_line_item_id: display_line_item.id,
            budget_loc: 100_010.01
          )

          expect(subject).not_to be_valid
          expect(subject.errors.full_messages).to include(
            'Budget sum of monthly budgets can\'t be more then line item budget'
          )
        end
      end
    end
  end

  def display_line_item(opts = {})
    @_display_line_item ||= create :display_line_item, opts
  end

  def display_line_item_budget(opts = {})
    @_display_line_item_budget ||= create :display_line_item_budget, opts
  end
end
