require 'rails_helper'

feature 'Teams' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating a new parent team' do
    before do
      login_as user, scope: :user
      visit '/settings/teams'
      expect(page).to have_css('#teams')
    end

    scenario 'creating a team' do
      find('.add-team').click

      expect(page).to have_css('#team-modal')

      within '#team-modal' do
        fill_in 'name', with: 'Test Team'

        click_on 'Create'
      end

      expect(page).to have_no_css('#team-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text 'Test Team'
        end
      end
    end
  end

  describe 'creating a new child team' do
    let!(:parent) { create :parent_team, company: company }
    before do
      login_as user, scope: :user
      visit "/settings/teams/#{parent.id}"
      expect(page).to have_css('#team')
    end

    scenario 'creating a team' do
      find('.add-team').click

      expect(page).to have_css('#team-modal')

      within '#team-modal' do
        fill_in 'name', with: 'Test Child Team'
        ui_select('parent', parent.name)
        click_on 'Create'
      end

      expect(page).to have_no_css('#team-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text 'Test Child Team'
        end
      end
    end
  end
end
