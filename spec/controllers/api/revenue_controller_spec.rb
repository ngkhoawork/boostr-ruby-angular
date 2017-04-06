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

  describe 'GET #index' do
    context 'user' do
      before do
        create(:io_member, user: user, io: io, share: 100)
        2.times { create :content_fee, io: io, product: product, budget: 20_000 }
      end

      it 'has proper revenue data' do
        get :index, format: :json, time_period_id: time_period.id, member_id: user.id.to_s
        response_json = JSON.parse(response.body)

        expect(response_json[0]['name']).to eq(io.name)
        expect(response_json[0]['advertiser']).to eq(advertiser.name)
        expect(response_json[0]['budget']).to eq('40000.0')
        expect(response_json[0]['sum_period_budget']).to eq(40000.0)
      end
    end

    context 'team' do
      before do
        create(:io_member, user: user, io: io, share: 100)
        2.times { create :content_fee, io: io, product: product, budget: 20_000 }

        create(:io_member, user: another_user, io: io_for_another_user, share: 80)
        2.times { create :content_fee, io: io_for_another_user, product: product, budget: 10_000 }
      end

      it 'has proper revenue data' do
        get :index, format: :json, time_period_id: time_period.id, team_id: team.id.to_s
        response_json = response_json(response.body)

        expect(select_values(response_json, 'name')).to include(io.name && io_for_another_user.name)
        expect(select_values(response_json, 'advertiser')).to include(advertiser.name)
        expect(select_values(response_json, 'budget')).to include('40000.0' && '20000.0')
        expect(select_values(response_json, 'sum_period_budget')).to include(40000.0 && 20000.0)
      end
    end
  end

  private

  def response_json(body)
    @_response_json ||= JSON.parse(body)
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


  def advertiser
    @_advertiser ||= create(:client)
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
end
