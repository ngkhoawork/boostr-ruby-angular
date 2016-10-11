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

    scenario 'shows a list of objects', js: true do
      within '#custom-values' do
        expect(page).to have_css('.well.primary', count: 4)

        within '#objects' do
          expect(page).to have_css '.well', count: 5
        end
      end
    end

    scenario 'shows a list of fields', js: true do
      within '#custom-values' do
        within '#objects' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#fields' do
          expect(page).to have_css '.well', count: 4

          within '.well:nth-child(3)' do
            expect(page).to have_text 'Client Types'
          end
        end
      end
    end

    scenario 'shows a list of options', js: true do
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
        end
      end
    end

    scenario 'lists and allows to add suboptions to Category option only', js: true do
      within '#custom-values' do
        within '#objects' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#fields' do
          find('.well:nth-child(3)').trigger('click')
        end

        within '#options' do
          find('li:last-child').trigger('click')
        end

        within '#suboptions' do
          expect(page).to have_css('.add[disabled]')
        end

        within '#fields' do
          within '.well:nth-child(2)' do
            expect(page).to have_text 'Categories'
          end
          find('.well:nth-child(2)').trigger('click')
        end

        within '#options' do
          find('.add').trigger('click')
          within 'li:last-child' do
            find('.title', visible: false).trigger('click')
            fill_in 'name', with: 'Dealerships'
            find('.editable-input').native.send_keys(:Enter)
          end
          find('li:last-child').trigger('click')
        end

        within '#suboptions' do
          sleep 2
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
