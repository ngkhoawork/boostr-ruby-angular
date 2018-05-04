require 'rails_helper'

RSpec.describe DealProductCf, type: :model do
  describe 'validations' do
    subject { instance.save }

    let!(:percentage_cf_name) do
      create(
        :deal_product_cf_name,
        field_type: 'percentage',
        field_index: 1,
        field_label: FFaker::HipsterIpsum.word,
        company: company
      )
    end

    let(:attrs) { { 'percentage1' => percentage_value, deal_product: deal_product, company: company } }
    let(:percentage_value) { 50 }

    before { allow_any_instance_of(DealProductCf).to receive(:calculate_sum).and_return(nil) }

    it do
      expect{subject}.to change{DealProductCf.count}.by(1)
      expect(last_created_deal_product_cf.percentage1).to eq percentage_value
    end

    context 'and when percentage_value is not numeric' do
      let(:percentage_value) { '101ABC' }

      it do
        expect{subject}.not_to change{DealProductCf.count}
        expect(
          row_field_errors(instance, percentage_cf_name.field_label)
        ).to match /must be a number/i
      end
    end

    context 'and when percentage_value is out of range' do
      let(:percentage_value) { 101 }

      it do
        expect{subject}.not_to change{DealProductCf.count}
        expect(
          row_field_errors(instance, percentage_cf_name.field_label)
        ).to match /must be in 0-100 range/i
      end
    end
  end

  private

  def instance
    @_instance ||= described_class.new(attrs)
  end

  def row_field_errors(record, field)
    record.errors[field].join(', ')
  end

  def company
    @_company ||= create(:company)
  end

  def deal_product
    @_deal_product ||= create(:deal_product, deal: deal, product: product)
  end

  def deal
    @_deal ||= create(:deal, company: company)
  end

  def product
    @_product ||= create(:product, company: company)
  end

  def last_created_deal_product_cf
    @_last_created_deal_product_cf ||= DealProductCf.last
  end
end
