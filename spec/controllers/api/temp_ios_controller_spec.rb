require 'rails_helper'

describe Api::TempIosController do
  before { sign_in user }

  describe 'GET #index' do
    before { create_list :temp_io, 5, company: company }

    it 'has appropriate count of record in response' do
      get :index, format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(5)
    end

    it 'has ios related to specific advertiser' do
      create :temp_io, company: company, advertiser: 'Google'

      get :index, name: 'Google', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['advertiser']).to eq('Google')
    end

    it 'has ios related to specific agency' do
      create :temp_io, company: company, agency: 'Facebook'

      get :index, name: 'Facebook', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['agency']).to eq('Facebook')
    end

    it 'has appropriate ios if filter by name' do
      create :temp_io, company: company, name: 'Io 432'

      get :index, name: '432', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['name']).to eq('Io 432')
    end

    it 'has appropriate ios if filter by started date' do
      create :temp_io, company: company, start_date: '2016-06-15'

      get :index, end_date: '2016-06-20', start_date: '2016-06-10', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
