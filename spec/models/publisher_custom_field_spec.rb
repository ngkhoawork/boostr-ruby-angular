require 'rails_helper'

RSpec.describe PublisherCustomField, type: :model do
  describe 'validations' do
    subject { instance.save }

    let(:attrs) { { 'percentage1' => percentage_value, publisher: publisher, company: company } }

    let!(:percentage_cf_name) do
      create(
        :publisher_custom_field_name,
        field_type: 'percentage',
        field_index: 1,
        field_label: FFaker::HipsterIpsum.word,
        company: company
      )
    end

    let(:percentage_value) { 50 }

    it do
      expect{subject}.to change{PublisherCustomField.count}.by(1)
      expect(last_created_publisher_cf.percentage1).to eq percentage_value
    end

    context 'and when percentage_value is not numeric' do
      let(:percentage_value) { '101ABC' }

      it do
        expect{subject}.not_to change{PublisherCustomField.count}
        expect(
          row_field_errors(instance, percentage_cf_name.field_label)
        ).to match /must be a number/i
      end
    end

    context 'and when percentage_value is out of range' do
      let(:percentage_value) { 101 }

      it do
        expect{subject}.not_to change{PublisherCustomField.count}
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

  def publisher
    @_publisher ||= create(:publisher, name: 'Amazon', company: company)
  end

  def last_created_publisher_cf
    @_last_created_publisher_cf ||= PublisherCustomField.last
  end
end
