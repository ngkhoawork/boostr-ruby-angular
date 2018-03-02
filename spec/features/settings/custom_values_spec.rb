require 'rails_helper'

feature 'Custom Values' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'settings page' do
    before do
      login_as user, scope: :user
      visit '/settings/custom_values'
    end

    it 'shows a list of objects', js: true do
      within '#custom-values' do
        expect(page).to have_css '#fields .well', count: 5

        expect(page).to have_css '#objects .well', count: 9
      end
    end

    it 'shows a list of fields', js: true do
      within '#custom-values' do
        within '#objects' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#fields' do
          expect(page).to have_css '.well', count: 6

          within '.well:nth-child(3)' do
            expect(page).to have_text 'Client Types'
          end
        end
      end
    end

    it 'shows a list of options', js: true do
      within '#custom-values' do
        within '#objects' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#fields' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#options' do
          expect(page).to have_css('li', count: 2)
          expect(find('li:first-child')).to have_no_css '.delete'

          within 'li:last-child' do
            expect(find('input').value).to have_text('Agency')
          end

          find('.add').trigger('click')
          expect(page).to have_css 'li', count: 3

          within 'li:last-child' do
            find('.title', visible: false).trigger('click')
            find('input').set('Taco')

            expect(find('input').value).to have_text('Taco')

            expect(page).to have_css '.delete', visible: false
            find('.delete', visible: false).trigger('click')
          end

          expect(page).to have_css 'li', count: 2
        end
      end
    end
  end
end
