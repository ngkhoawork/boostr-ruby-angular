require 'rails_helper'

describe Csv::ActivityDetailDecorator do
  let!(:company) { create :company, :fast_create_company }

  it 'decorate activity successfully and return expected values' do
    expect(activity_detail_decorator.date).to eq activity_date
    expect(activity_detail_decorator.type).to eq activity_type
    expect(activity_detail_decorator.comments).to eq activity.comment
    expect(activity_detail_decorator.advertiser).to eq activity.client.name
    expect(activity_detail_decorator.agency).to eq ''
    expect(activity_detail_decorator.contacts).to eq activity_contact
    expect(activity_detail_decorator.deal).to eq activity.deal.name
    expect(activity_detail_decorator.creator).to eq activity.creator.name
    expect(activity_detail_decorator.team).to eq nil
  end

  private

  def activity_detail_decorator
    @_activity_detail_decorator ||= described_class.new(activity)
  end

  def activity
    @_activity ||= create :activity
  end

  def activity_date
    activity.happened_at.strftime('%m/%d/%Y')
  end

  def activity_type
    activity.activity_type_name
  end

  def activity_contact
    activity.contacts.pluck(:name).join("\n")
  end
end
