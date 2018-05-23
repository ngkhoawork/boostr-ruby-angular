require 'rails_helper'

RSpec.describe Api::SearchController, type: :controller do
  before do
    sign_in user
  end

  describe "GET #all" do
    it 'returns a list of search results' do
      create :deal, name: 'test', company: company

      get :all, query: 'test', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
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
