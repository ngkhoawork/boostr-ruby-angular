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
