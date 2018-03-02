require 'rails_helper'

feature 'Stages' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating and updating a stage' do
    before do
      login_as user, scope: :user
      visit '/settings/stages'
      expect(page).to have_css('#stages')
    end

    it 'creating a stage', js: true do
      find('add-button', text: 'Add').trigger('click')

      expect(page).to have_css('#stage-modal')

      within '#stage-modal' do
        fill_in 'name', with: 'Test Stage'
        fill_in 'probability', with: '64'
        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#stage-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr' do
          expect(page).to have_text 'Test Stage'
          expect(page).to have_text '64%'
        end

        find('i.fa-pencil', visible: false).trigger('click')
      end

      expect(page).to have_css('#stage-modal')

      within '#stage-modal' do
        fill_in 'name', with: 'Test'
        fill_in 'probability', with: '80'

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#stage-modal')

      within 'table tbody' do
        expect(find('tr:first-child td:first-child')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(2)')).to have_text('80%')
      end
    end
  end
end
