require 'rails_helper'

RSpec.describe Api::V2::StatesController, type: :controller do
  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'returns success' do
      get :index

      expect(response).to be_success
    end

    it 'provides list of states' do
      get :index

      expect(json_response).to eq(
        states.as_json
      )
    end
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def states
    [
      { abbreviation: 'AL', name: 'Alabama', },
      { abbreviation: 'AK', name: 'Alaska', },
      { abbreviation: 'AZ', name: 'Arizona', },
      { abbreviation: 'AR', name: 'Arkansas', },
      { abbreviation: 'CA', name: 'California', },
      { abbreviation: 'CO', name: 'Colorado', },
      { abbreviation: 'CT', name: 'Connecticut', },
      { abbreviation: 'DE', name: 'Delaware', },
      { abbreviation: 'DC', name: 'District Of Columbia', },
      { abbreviation: 'FL', name: 'Florida', },
      { abbreviation: 'GA', name: 'Georgia', },
      { abbreviation: 'HI', name: 'Hawaii', },
      { abbreviation: 'ID', name: 'Idaho', },
      { abbreviation: 'IL', name: 'Illinois', },
      { abbreviation: 'IN', name: 'Indiana', },
      { abbreviation: 'IA', name: 'Iowa', },
      { abbreviation: 'KS', name: 'Kansas', },
      { abbreviation: 'KY', name: 'Kentucky', },
      { abbreviation: 'LA', name: 'Louisiana', },
      { abbreviation: 'ME', name: 'Maine', },
      { abbreviation: 'MD', name: 'Maryland', },
      { abbreviation: 'MA', name: 'Massachusetts', },
      { abbreviation: 'MI', name: 'Michigan', },
      { abbreviation: 'MN', name: 'Minnesota', },
      { abbreviation: 'MS', name: 'Mississippi', },
      { abbreviation: 'MO', name: 'Missouri', },
      { abbreviation: 'MT', name: 'Montana', },
      { abbreviation: 'NE', name: 'Nebraska', },
      { abbreviation: 'NV', name: 'Nevada', },
      { abbreviation: 'NH', name: 'New Hampshire', },
      { abbreviation: 'NJ', name: 'New Jersey', },
      { abbreviation: 'NM', name: 'New Mexico', },
      { abbreviation: 'NY', name: 'New York', },
      { abbreviation: 'NC', name: 'North Carolina', },
      { abbreviation: 'ND', name: 'North Dakota', },
      { abbreviation: 'OH', name: 'Ohio', },
      { abbreviation: 'OK', name: 'Oklahoma', },
      { abbreviation: 'OR', name: 'Oregon', },
      { abbreviation: 'PA', name: 'Pennsylvania', },
      { abbreviation: 'RI', name: 'Rhode Island', },
      { abbreviation: 'SC', name: 'South Carolina', },
      { abbreviation: 'SD', name: 'South Dakota', },
      { abbreviation: 'TN', name: 'Tennessee', },
      { abbreviation: 'TX', name: 'Texas', },
      { abbreviation: 'UT', name: 'Utah', },
      { abbreviation: 'VT', name: 'Vermont', },
      { abbreviation: 'VA', name: 'Virginia', },
      { abbreviation: 'WA', name: 'Washington', },
      { abbreviation: 'WV', name: 'West Virginia', },
      { abbreviation: 'WI', name: 'Wisconsin', },
      { abbreviation: 'WY', name: 'Wyoming' }
    ]
  end
end
