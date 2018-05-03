require 'rails_helper'

RSpec.describe AccountCf, type: :model do
  describe 'validations' do
    subject { instance.save }

    let!(:percentage_cf_name) do
      create(
        :account_cf_name,
        field_type: 'percentage',
        field_index: 1,
        field_label: FFaker::HipsterIpsum.word,
        company: company
      )
    end

    let(:attrs) { { 'percentage1' => percentage_value, client: client, company: company } }
    let(:percentage_value) { 50 }

    it do
      expect{subject}.to change{AccountCf.count}.by(1)
      expect(last_created_account_cf.percentage1).to eq percentage_value
    end

    context 'and when percentage_value is not numeric' do
      let(:percentage_value) { '101ABC' }

      it do
        expect{subject}.not_to change{AccountCf.count}
        expect(
          row_field_errors(instance, percentage_cf_name.field_label)
        ).to match /must be a number/i
      end
    end

    context 'and when percentage_value is out of range' do
      let(:percentage_value) { 101 }

      it do
        expect{subject}.not_to change{AccountCf.count}
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

  def client
    @_client ||= create(:client, client_type_id: advertiser_type_id(company), company: company)
  end

  def last_created_account_cf
    @_last_created_account_cf ||= AccountCf.last
  end
end
