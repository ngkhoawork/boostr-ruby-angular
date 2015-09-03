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

    scenario 'shows a list of objects, fields and their values' do
      within '#custom-values' do
        expect(page).to have_css('.well.primary', count: 3)

        within '#values' do
          expect(page).to have_css('.well', count: 2)

          within '.well:last-child' do
            expect(page).to have_text(stage.name)
            find('.title').click
            fill_in 'stage-name', with: 'Taco'
            find('.editable-input').native.send_keys(:return)
          end

          page.driver.browser.switch_to.alert.accept

          within '.well:last-child' do
            expect(page).to have_text('Taco')
          end

          within '.well:first-child' do
            find('a').click
          end

          within '.well:nth-child(2)' do
            expect(page).to have_text('New Stage')
          end
        end
      end
    end
  end
end