require 'rails_helper'

RSpec.describe Api::RevenueController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company, email: 'msmith@buzzfeed.com' }
  let!(:another_user) { create :user, company: company, email: 'tjones@buzzfeed.com' }

  before do
    sign_in user
  end

  describe "POST #create" do
    let(:csv_file) { ActionDispatch::Http::UploadedFile.new(tempfile: File.new("#{Rails.root}/spec/support/revenue_example.csv")) }

    it 'calls import on Revenue and returns success' do
      post :create, file: csv_file, format: :json
      expect(response).to be_success
    end
  end

  describe '#report_by_category' do
    let!(:account_revenue_fact) do
      create(
        :account_revenue_fact,
        account_dimension: account_dimension,
        revenue_amount: 10_000,
        company: user.company,
        category_id: category.id,
        time_dimension: time_dimension
      )
    end
    let(:params) do
      {
        format: :json,
        start_date: time_dimension.start_date,
        end_date: time_dimension.end_date
      }
    end
    subject { get :report_by_category, params }

    before(:each) { subject }

    context 'when params include appropriate "category_ids"' do
      let(:params) { super().merge(category_ids: [category.id]) }

      it 'has an appropriate structure' do
        expect(response).to be_success
        expect(response_json).to be_kind_of Array
        expect(response_item).to have_key :category_name
        expect(response_item).to have_key :year
        expect(response_item).to have_key :revenues
        expect(response_item).to have_key :total_revenue
        expect(response_item[:revenues]).to be_kind_of Hash
      end
      it { expect(response_item[:category_name]).to eq category.name }

      context 'and when params include appropriate "region_id"' do
        let(:params) { super().merge(client_region_ids: [region.id]) }

        it { expect(response_json).not_to be_empty }
      end

      context 'and when options include appropriate "segment_id"' do
        let(:params) { super().merge(client_segment_ids: [segment.id]) }

        it { expect(response_json).not_to be_empty }
      end

      context 'and when options does not include appropriate "region_id"' do
        let(:params) { super().merge(client_region_ids: [-1]) }

        it { expect(response_json).to be_empty }
      end

      context 'and when options does not include appropriate "segment_id"' do
        let(:params) { super().merge(client_segment_ids: [-1]) }

        it { expect(response_json).to be_empty }
      end
    end

    context 'when params does not include appropriate "category_ids"' do
      let(:params) { super().merge(category_ids: [-1]) }

      it { expect(response_item).to be_nil }
    end
  end

  describe '#report_by_account' do
    let!(:account_revenue_fact) do
      create(
        :account_revenue_fact,
        account_dimension: account_dimension,
        revenue_amount: 10_000,
        company: user.company,
        category_id: category.id,
        time_dimension: time_dimension
      )
    end
    let(:params) do
      {
        format: :json,
        start_date: time_dimension.start_date,
        end_date: time_dimension.end_date
      }
    end
    subject { get :report_by_account, params }

    before(:each) { subject }

    context 'when params include appropriate "category_ids"' do
      let(:params) { super().merge(category_ids: [category.id]) }

      it 'has an appropriate structure' do
        expect(response).to be_success
        expect(response_json).to be_kind_of Array
        expect(response_item).to have_key :name
        expect(response_item).to have_key :client_type
        expect(response_item).to have_key :category_name
        expect(response_item).to have_key :region_name
        expect(response_item).to have_key :segment_name
        expect(response_item).to have_key :seller_names
        expect(response_item).to have_key :revenues
        expect(response_item).to have_key :total_revenue
        expect(response_item[:revenues]).to be_kind_of Array
      end
      it { expect(response_item[:category_name]).to eq category.name }

      context 'and when params include appropriate "region_ids"' do
        let(:params) { super().merge(client_region_ids: [region.id]) }

        it { expect(response_json).not_to be_empty }
      end

      context 'and when options include appropriate "segment_ids"' do
        let(:params) { super().merge(client_segment_ids: [segment.id]) }

        it { expect(response_json).not_to be_empty }
      end

      context 'and when options does not include appropriate "region_ids"' do
        let(:params) { super().merge(client_region_ids: [-1]) }

        it { expect(response_json).to be_empty }
      end

      context 'and when options does not include appropriate "segment_id"' do
        let(:params) { super().merge(client_segment_ids: [-1]) }

        it { expect(response_json).to be_empty }
      end
    end

    context 'when params does not include appropriate "category_ids"' do
      let(:params) { super().merge(category_ids: [-1]) }

      it { expect(response_item).to be_nil }
    end
  end

  private

  def response_json
    @_response_json ||= JSON.parse(response.body, symbolize_names: true)
  end

  def response_item
    @_response_item ||= response_json[0]
  end

  def select_values(json, key)
    json.inject([]) { |values, obj| values << obj[key] }
  end

  def time_period
    @_time_period ||= create :time_period, start_date: '2017-01-01', end_date: '2017-03-31', company: company
  end

  def io
    @_io ||= create :io,
             advertiser: advertiser,
             company: user.company,
             start_date: '2017-01-01',
             end_date: '2017-03-31',
             deal: deal
  end

  def io_for_another_user
    @_io_for_another_user ||= create :io,
                              advertiser: advertiser,
                              company: another_user.company,
                              start_date: '2017-01-01',
                              end_date: '2017-03-31',
                              deal: another_deal
  end

  def deal
    @_deal ||= create :deal, products: [product]
  end

  def another_deal
    @_another_deal ||= create :deal, products: [product]
  end

  def product
    @_product ||= create :product
  end

  def team
    @_team ||= create :parent_team, members: [user, another_user], company: company
  end

  def category_field
    @_category_field ||= create(:field, name: 'Category', subject_type: 'Client')
  end

  def region_field
    @_region_field ||= create(:field, name: 'Region', subject_type: 'Client')
  end

  def segment_field
    @_segment_field ||= create(:field, name: 'Segment', subject_type: 'Client')
  end

  def category
    @_category ||= create(:option, field: category_field, company: company)
  end

  def region
    @_region ||= create(:option, field: region_field, company: company)
  end

  def segment
    @_segment ||= create(:option, field: segment_field, company: company)
  end

  def holding_company
    @_holding_company ||= create(:holding_company)
  end

  def advertiser
    @_advertiser ||=
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
    @_account_dimension ||= advertiser.account_dimensions.last
  end

  def time_dimension
    @_time_dimension ||=
      create(
        :time_dimension,
        start_date: Date.today.beginning_of_month,
        end_date: Date.today.end_of_month,
        days_length: Time.days_in_month(Time.current.month)
      )
  end
end
