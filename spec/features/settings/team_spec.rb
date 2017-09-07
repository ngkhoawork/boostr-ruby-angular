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

    scenario 'creating a team', js: true do
      find('.add-team').trigger('click')

      expect(page).to have_css('#team-modal')

      within '#team-modal' do
        fill_in 'name', with: 'Test Team'
        ui_select('leader', user.name)
        find_button('Create').trigger('click')
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

    scenario 'creating a team', js: true do
      find('.add-team').trigger('click')

      expect(page).to have_css('#team-modal')

      within '#team-modal' do
        fill_in 'name', with: 'Test Child Team'
        ui_select('parent', parent.name)
        find_button('Create').trigger('click')
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

  describe 'update a team' do
    let!(:parent) { create :parent_team, company: company }
    let!(:user) { create :user, company: company }

    before do
      login_as user, scope: :user
      visit '/settings/teams/'
      expect(page).to have_css('#teams')
    end

    scenario 'pops up an edit team modal and updates a team', js: true do
      within 'table tbody' do
        find('tr:first-child').hover
        find('.edit-team').trigger('click')
      end

      expect(page).to have_css('#team-modal')

      within '#team-modal' do
        fill_in 'name', with: 'Test'
        ui_select('leader', user.name)

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#team-modal')

      within 'table tbody' do
        expect(find('tr:first-child td:first-child')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(2)')).to have_text(user.name)
      end
    end
  end

  describe 'deleting a team' do
    let!(:teams) { create_list :parent_team, 3, company: company }

    before do
      teams.sort_by!(&:name)
      login_as user, scope: :user
      visit '/settings/teams/'
      expect(page).to have_css('#teams')
    end

    scenario 'removes the team from the page', js: true do
      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 3)
        find('tr:first-child').hover
        within 'tr:first-child' do
          find('.delete-team').trigger('click')
        end
      end

      wait_for_ajax 1

      expect(page).to have_css('.table-wrapper tbody tr', count: 2)

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
        find('tr:first-child').hover
        within 'tr:first-child' do
          find('.delete-team').trigger('click')
        end
      end

      expect(page).to have_css('.table-wrapper tbody tr', count: 1)
    end
  end
end
