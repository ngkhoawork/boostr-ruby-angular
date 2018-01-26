require 'rails_helper'

describe Dataexport::IoSerializer do
  it 'serializes io data' do
    expect(serializer.id).to eq(io.id)
    expect(serializer.io_number).to eq(io.io_number)
    expect(serializer.advertiser_id).to eq(io.advertiser_id)
    expect(serializer.agency_id).to eq(io.agency_id)
    expect(serializer.budget_usd).to eq(io.budget)
    expect(serializer.budget).to eq(io.budget_loc)
    expect(serializer.start_date).to eq(io.start_date)
    expect(serializer.end_date).to eq(io.end_date)
    expect(serializer.external_io_number).to eq(io.external_io_number)
    expect(serializer.created).to eq(io.created_at)
    expect(serializer.last_updated).to eq(io.updated_at)
    expect(serializer.name).to eq(io.name)
    expect(serializer.deal_id).to eq(io.deal_id)
    expect(serializer.currency).to eq(io.curr_cd)
  end

  private

  def serializer
    @_serializer ||= described_class.new(io)
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

  def agency
    @_agency ||= create :client
  end
end
