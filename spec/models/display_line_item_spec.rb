require 'rails_helper'

RSpec.describe DisplayLineItem, type: :model do
  it 'closes deal display product when line item comes from datafeed' do
    deal_product

    deal.update(stage: closed_won_stage, updated_by: 0)

    expect(deal_product.reload.open).to be true

    create :display_line_item, io: deal.io, dont_update_parent_budget: true

    expect(deal_product.reload.open).to be false
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
end
