require 'rails_helper'

feature 'Revenue' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'uploading a csv' do

    before do
      login_as user, scope: :user
      visit "/revenue"
      expect(page).to have_css('#revenue')
    end

    scenario 'shows the modal and uploads a csv' do
      find('.upload').click()

      expect(page).to have_css('#revenue_upload_modal')

      page.execute_script <<-JS
        fakeFileInput = window.$('<input/>').attr({ id: 'fakeFileInput', type: 'file' }).appendTo('body');
      JS

      page.attach_file('fakeFileInput', "#{Rails.root}/spec/support/revenue_example.csv")

      page.execute_script <<-JS
        var scope = angular.element('#browse').scope();
        scope.upload([fakeFileInput.get(0).files[0]]);
      JS

      click_button('Done')

      expect(page).to have_no_css('#revenue_upload_modal')

      within 'table tbody' do
        expect(page).to have_css('tr', count: 13)
      end
    end

    scenario 'shows an error message when you upload a bad csv' do
      find('.upload').click()

      expect(page).to have_css('#revenue_upload_modal')

      page.execute_script <<-JS
        fakeFileInput = window.$('<input/>').attr({ id: 'fakeFileInput', type: 'file' }).appendTo('body');
      JS

      page.attach_file('fakeFileInput', "#{Rails.root}/spec/support/revenue_example_2.csv")

      page.execute_script <<-JS
        var scope = angular.element('#browse').scope();
        scope.upload([fakeFileInput.get(0).files[0]]);
      JS

      within '#revenue_upload_modal' do
        expect(page).to have_css('.progress-bar', visible: true)
        expect(page).to have_css('.alert.alert-danger')

        within '.alert' do
          expect(page).to have_text('Row 15 contains errors: ')
        end
      end

    end
  end

end