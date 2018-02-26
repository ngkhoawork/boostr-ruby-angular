require 'rails_helper'

describe ContentFeeProductBudget do
  context 'associations' do
    it { should belong_to(:content_fee) }
  end

  let(:budget) { 1000.to_f }

  describe '#corrected_daily_budget' do
    context 'for 1 day lenght' do
      let(:io_start) { Time.zone.today }
      let(:io_end) { Time.zone.today }

      it { expect(content_fee_product_budget.corrected_daily_budget(io_start, io_end)).to eql(budget) }
    end

    context 'for -1 day lenght' do
      let(:io_start) { Time.zone.yesterday - 1.day }
      let(:io_end) { Time.zone.yesterday }

      it { expect(content_fee_product_budget.corrected_daily_budget(io_start, io_end)).to eql(0) }
    end
  end

  private

  def content_fee_product_budget
    @_content_fee_product_budget ||= create :content_fee_product_budget,
                                            start_date: Time.zone.today,
                                            end_date: Time.zone.today,
                                            budget: budget
  end
end
