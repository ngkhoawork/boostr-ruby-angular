require 'rails_helper'

describe Csv::Quota do
  let!(:company) { create :company, :fast_create_company }
  let!(:time_period) { create :time_period, name: 'Q3-2017', company: company }

  context 'import' do
    it 'create new quota' do
      expect {
        Csv::Quota.import(file, user.id, 'quota.csv')
      }.to change(Quota, :count).by(2)

      quota = company.quotas.last

      expect(quota.value).to eq(1500)
      expect(quota.time_period_id).to eq(time_period.id)
      expect(quota.user_id).to eq(user.id)
    end

    it 'update existed quota' do
      quota = company.quotas.create(value: 1000, time_period_id: time_period.id, user_id: user.id, value_type: 'net', product_type: 'ProductFamily', product_id: product_family.id)

      expect {
        Csv::Quota.import(file, user.id, 'quota.csv')
      }.to change(Quota, :count).by(1)

      expect(quota.reload.value).to eq(1500)
    end
  end

  private

  def user
    @_user ||= create :user, company: company, email: 'test@user.com'
  end

  def product
    @_product ||= create :product, name: 'quota', company: company
  end

  def product_family
    @_product_family ||= create :product_family, name: 'quota', company: company
  end

  def file
    @_file = CSV.generate do |csv|
      csv << ['Time Period', 'Email', 'Quota', 'Type', 'Product', 'Product Family']
      csv << ['Q3-2017', 'test@user.com', '500', 'Gross', product.name, '']
      csv << ['Q3-2017', 'test@user.com', '1500', 'Net', '', product_family.name]
    end
  end
end
