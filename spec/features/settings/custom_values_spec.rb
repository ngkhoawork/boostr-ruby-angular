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
          end
        end
      end
    end
  end
end