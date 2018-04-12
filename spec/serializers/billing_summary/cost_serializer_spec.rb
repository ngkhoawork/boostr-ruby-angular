require 'rails_helper'

describe BillingSummary::CostSerializer do
  let!(:company) { create :company }

  it 'serializes cost data' do
    expect(serializer.id).to eq(cost.id)
    expect(serializer.product).to eq(cost.product)
    expect(serializer.io_id).to eq(io.id)
    expect(serializer.values).to eq(cost.values)
  end

  private

  def serializer
    @_serializer ||= described_class.new(cost)
  end

  def io
    @_io ||= create :io, advertiser: advertiser, agency: agency, company: company
  end

  def company
    @_company ||= create :company
  end

  def advertiser
    @_advertiser ||= create :client
  end

  def product
    @_product ||= create :product
  end

  def agency
    @_agency ||= create :client
  end

  def cost
    @_cost ||= create :cost, io: io, product: product
  end
end
