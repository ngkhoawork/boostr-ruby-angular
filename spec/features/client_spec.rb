require 'rails_helper'

feature 'Clients' do
  let(:user) { create :user }

  before do
    login_as user
    visit '/clients'
    expect(page).to have_css('#clients')
  end

  describe 'subnav' do
    scenario 'pops up a new client modal' do
      click_link('New Client')
      expect(page).to have_css('#client_modal')
    end
  end
end