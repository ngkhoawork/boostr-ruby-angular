require 'rails_helper'

describe Csv::ActivitySummary::AccountDecorator do
  before { create_activity }

  it 'decorate account successfully and return expected values' do
    expect(account_decorator.name).to eq activity.client.name
    expect(account_decorator.total).to eq client.activities.count
    activity_types_names.each do |type|
      expect(account_decorator.send(type)).to eq count_for_activity_type(type)
    end
  end

  private

  def account_decorator
    described_class.new(client, options)
  end

  def client
    @_client ||= create :client, company: company
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
    @_activity ||= create :activity, client: client, company: company, deal: deal, happened_at: Date.new(2017, 2, 2)
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
