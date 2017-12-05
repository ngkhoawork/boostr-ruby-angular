require 'rails_helper'

describe Report::RevenueByAccountService do
  before(:all) { account_revenue_fact }
  after(:all) { clear_test_data }

  describe '#perform' do
    let(:options) do
      {
        company_id: company.id,
        category_ids: [category.id],
        start_date: time_dimension.start_date,
        end_date: time_dimension.end_date
      }
    end
    let(:instance) { described_class.new(options) }
    let(:response_item) { subject[0] }

    subject { instance.perform }

    context 'when options include appropriate "category_ids"' do
      it 'is array with an appropriate structure' do
        expect(subject).to be_kind_of Array
        expect(response_item).to respond_to :name
        expect(response_item).to respond_to :client_type
        expect(response_item).to respond_to :client_category_name
        expect(response_item).to respond_to :client_region_name
        expect(response_item).to respond_to :client_segment_name
        expect(response_item).to respond_to :month_revenues
        expect(response_item).to respond_to :total_revenue
        expect(response_item.month_revenues).to be_kind_of Hash
      end
      it 'returns array with an element fitting to filters' do
        expect(response_item.client_category_name).to eq category.name
      end

      context 'and when options include appropriate "region_id"' do
        let(:options) { super().merge(client_region_ids: [region.id]) }

        it 'returns array with an element fitting to filters' do
          expect(response_item.client_region_name).to eq region.name
        end
      end

      context 'and when options include appropriate "segment_id"' do
        let(:options) { super().merge(client_segment_ids: [segment.id]) }

        it 'returns array with an element fitting to filters' do
          expect(response_item.client_segment_name).to eq segment.name
        end
      end

      context 'and when options does not include appropriate "region_id"' do
        let(:options) { super().merge(client_region_ids: [-1]) }

        it { expect(response_item).to eq nil }
      end

      context 'and when options does not include appropriate "segment_id"' do
        let(:options) { super().merge(client_segment_ids: [-1]) }

        it { expect(response_item).to eq nil }
      end
    end

    context 'when options does not include appropriate "category_ids"' do
      let(:options) { super().merge(category_ids: [-1]) }

      it { expect(response_item).to eq nil }
    end
  end

  private

  def account_revenue_fact
    @account_revenue_fact ||= create(
      :account_revenue_fact,
      account_dimension: account_dimension,
      revenue_amount: 10_000,
      company: company,
      category_id: category.id,
      time_dimension: time_dimension
    )
  end

  def company
    @company ||= create(:company)
  end

  def category_field
    @category_field ||= create(:field, name: 'Category', subject_type: 'Client')
  end

  def region_field
    @region_field ||= create(:field, name: 'Region', subject_type: 'Client')
  end

  def segment_field
    @segment_field ||= create(:field, name: 'Segment', subject_type: 'Client')
  end

  def category
    @category ||= create(:option, field: category_field, company: company)
  end

  def region
    @region ||= create(:option, field: region_field, company: company)
  end

  def segment
    @segment ||= create(:option, field: segment_field, company: company)
  end

  def holding_company
    @holding_company ||= create(:holding_company)
  end

  def advertiser
    @advertiser ||=
      create(
        :client,
        :advertiser,
        holding_company: holding_company,
        company: company,
        client_region_id: region.id,
        client_segment_id: segment.id
      )
  end

  def account_dimension
    @account_dimension ||= advertiser.account_dimensions.last
  end

  def time_dimension
    @time_dimension ||=
      create(
        :time_dimension,
        start_date: Date.today.beginning_of_month,
        end_date: Date.today.end_of_month,
        days_length: Time.days_in_month(Time.current.month)
      )
  end

  def clear_test_data
    (instance_variables - %i(@__inspect_output @__memoized @example)).sort.each do |var_name|
      record = instance_variable_get(var_name)
      record.respond_to?(:paranoia_column) ? record.really_destroy! : record.destroy
    end
  end
end
