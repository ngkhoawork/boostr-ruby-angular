require 'rails_helper'

feature 'Quotas' do
  let(:company) { create :company }
  let(:user) { create :user }
  let(:time_period) { create :time_period }
  let!(:quota) { create :quota, time_period: time_period, user: user }

  describe 'editing quotas' do
    before do
      login_as user, scope: :user
      visit '/settings/quotas'
    end

    it 'can edit a quota value inline and add a user', js: true do
      expect(page).to have_text user.name
      expect(find('.table-wrapper input').value).to have_text '10000'

      find('.table-wrapper input').set('2000')

      expect(find('.table-wrapper input').value).to have_text '2000'
    end
  end
end
