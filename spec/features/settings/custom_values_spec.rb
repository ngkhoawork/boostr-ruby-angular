require 'rails_helper'

feature 'Custom Values' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'settings page' do
    before do
      login_as user, scope: :user
      visit '/settings/custom_values'
      expect(page).to have_css('#custom-values')
    end

    scenario 'shows a list of objects, fields and their options', js: true do
      within '#custom-values' do
        expect(page).to have_css('.well.primary', count: 4)

        within '#objects' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#fields' do
          expect(page).to have_css '.well', count: 4

          within '.well:nth-child(3)' do
            expect(page).to have_text 'Client Types'
          end

          find('.well:nth-child(3)').trigger('click')
        end

        within '#options' do
          expect(page).to have_css('li', count: 2)
          expect(find('li:first-child')).to have_no_css '.delete'

          within 'li:last-child' do
            expect(page).to have_text('Agency')
          end

          find('.add').trigger('click')
          expect(page).to have_css 'li', count: 3

          within 'li:last-child' do
            find('.title', visible: false).trigger('click')
            fill_in 'name', with: 'Taco'
            find('.editable-input').native.send_keys(:Enter)
            expect(page).to have_no_css('.editable-input')

            expect(page).to have_text('Taco')

            expect(page).to have_css '.delete', visible: false
            find('.delete', visible: false).trigger('click')
          end

          expect(page).to have_css 'li', count: 2
          find('li:last-child').trigger('click')
        end

        within '#suboptions' do
          find('.add').trigger('click')
          expect(page).to have_css 'li', count: 1

          within 'li:last-child' do
            find('.title', visible: false).trigger('click')
            fill_in 'name', with: 'Subopt1'
            find('.editable-input').native.send_keys(:Enter)
            expect(page).to have_no_css('.editable_input')
          end

          expect(page).to have_text('Subopt1')
          expect(page).to have_css '.delete', visible: false
          find('.delete', visible: false).trigger('click')
          expect(page).to have_css 'li', count: 0
        end
      end
    end
  end
end