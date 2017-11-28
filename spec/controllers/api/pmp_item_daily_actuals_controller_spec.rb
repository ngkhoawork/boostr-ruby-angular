require 'rails_helper'

RSpec.describe Api::PmpItemDailyActualsController, type: :controller do
  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:another_pmp_item) { create :pmp_item, pmp: pmp, ssp: ssp }

    it 'returns paginated results' do
      create_list :pmp_item_daily_actual, 13, pmp_item: pmp_item

      get :index, pmp_id: pmp.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(10)
    end

    it 'returns results for specific pmp item' do
      create_list :pmp_item_daily_actual, 3, pmp_item: pmp_item
      create_list :pmp_item_daily_actual, 2, pmp_item: another_pmp_item

      get :index, pmp_id: pmp.id, pmp_item_id: pmp_item.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe 'POST #import' do
    it 'runs sidekiq worker and returns message' do
      expect do
        post :import, file: { s3_file_path: 'Fake' }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['message']).to start_with('Your file is being processed.')
      end.to change(CsvImportWorker.jobs, :size).by(1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, pmp: pmp, ssp: ssp
  end

  def ssp
    @_ssp ||= create :ssp
  end

  def pmp
    @_pmp ||= create :pmp, company: company, name: 'programmatic'
  end
end
