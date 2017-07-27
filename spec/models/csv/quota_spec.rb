require 'rails_helper'

describe Csv::Quota do
  context 'import' do
    it 'create new quota' do
      expect {
        Csv::Quota.import(file, user.id, 'quota.csv')
      }.to change(Quota, :count).by(1)

      quota = company.quotas.last

      expect(quota.value).to eq(500)
      expect(quota.time_period_id).to eq(time_period.id)
      expect(quota.user_id).to eq(user.id)
    end

    it 'update existed quota' do
      quota = company.quotas.create(value: 1000, time_period_id: time_period.id, user_id: user.id)

      expect {
        Csv::Quota.import(file, user.id, 'quota.csv')
      }.to_not change(Quota, :count)

      expect(quota.reload.value).to eq(500)
    end
  end

  private

  def company
    @_company ||= create :company, time_periods: [time_period]
  end

  def user
    @_user ||= create :user, company: company, email: 'test@user.com'
  end

  def time_period
    @_time_period ||= create :time_period, name: 'Q3-2017'
  end

  def file
    @_file = CSV.generate do |csv|
      csv << ['Time Period', 'Email', 'Quota']
      csv << ['Q3-2017', 'test@user.com', '500']
    end
  end
end
