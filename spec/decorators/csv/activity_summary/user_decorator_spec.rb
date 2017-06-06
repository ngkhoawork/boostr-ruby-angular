require 'rails_helper'

describe Csv::ActivitySummary::UserDecorator do
  before { create_activity }

  it 'decorate user successfully and return expected values' do
    expect(user_decorator.name).to eq activity.user.name
    expect(user_decorator.total).to eq user.activities.count
    activity_types_names.each do |type|
      expect(user_decorator.send(type)).to eq count_for_activity_type(type)
    end
  end

  private

  def user_decorator
    described_class.new(user, options)
  end

  def user
    @_user ||= create :user
  end

  def options
    {
      start_date: Date.new(2017, 2, 1),
      end_date: Date.new(2017, 2, 9)
    }
  end

  def company
    @_company ||= create :company
  end

  def create_activity
    @_activity ||= create :activity, user: user, company: company, deal: deal, happened_at: Date.new(2017, 2, 2)
  end

  def activity
    create_activity
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def activity_types_names
    company.activity_types.pluck(:name)
  end

  def count_for_activity_type(type)
    type.eql?(activity.activity_type_name) ? 1 : 0
  end
end
