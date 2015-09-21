require 'rails_helper'

feature 'Custom Values' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:stage) { create :stage, company: company }

  describe 'settings page' do
    before do
      login_as user, scope: :user
      visit '/settings/custom_values'
      expect(page).to have_css('#custom-values')
    end

    scenario 'shows a list of objects, fields and their values', js: true do
      within '#custom-values' do
        expect(page).to have_css('.well.primary', count: 3)

        within '#values' do
          expect(page).to have_css('.well', count: 2)

          within '.well:last-child' do
            expect(page).to have_text(stage.name)
            expect(page).to have_css('.open-button.active')
            find('.title').trigger('click')
            fill_in 'stage-name', with: 'Taco'
            find('.editable-input').native.send_keys(:Enter)
            expect(page).to have_no_css('.editable-input')
          end

          within '.well:last-child' do
            expect(page).to have_text('Taco')
            find('.close-button').trigger('click')
          end

          within '.well:last-child' do
            expect(page).to have_no_css('.open-button.active')
          end

          within '.well:first-child' do
            find('a').trigger('click')
          end

          within '.well:nth-child(2)' do
            expect(page).to have_text('New Stage')
          end
        end
      end
    end
  end
end