require 'rails_helper'

RSpec.describe DealCustomField, type: :model do
  describe 'validations' do
    subject { instance.save }

    let!(:percentage_cf_name) do
      create(
        :deal_custom_field_name,
        field_type: 'percentage',
        field_index: 1,
        field_label: FFaker::HipsterIpsum.word,
        company: company
      )
    end

    let(:attrs) { { 'percentage1' => percentage_value, deal: deal, company: company } }
    let(:percentage_value) { 50 }

    it do
      expect{subject}.to change{DealCustomField.count}.by(1)
      expect(last_created_deal_cf.percentage1).to eq percentage_value
    end

    context 'and when percentage_value is not numeric' do
      let(:percentage_value) { '101ABC' }

      it do
        expect{subject}.not_to change{DealCustomField.count}
        expect(
          row_field_errors(instance, percentage_cf_name.field_label)
        ).to match /must be a number/i
      end
    end

    context 'and when percentage_value is out of range' do
      let(:percentage_value) { 101 }

      it do
        expect{subject}.not_to change{DealCustomField.count}
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

  def deal
    @_deal ||= create(:deal, company: company)
  end

  def last_created_deal_cf
    @_last_created_deal_cf ||= DealCustomField.last
  end
end
