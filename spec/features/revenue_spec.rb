require 'rails_helper'

feature 'Revenue' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client) { create :client, company: company }
  let(:product) { create :product, company: company }

  describe 'uploading a good csv' do
    before do
      File.open("#{Rails.root}/tmp/good.csv", 'w+') { |f| f.write("#{good_csv_file(client, user, product)}") }
      login_as user, scope: :user
      visit '/revenue'
      expect(page).to have_css('#revenue')
    end

    scenario 'shows the modal and uploads a csv', js: true do
      find('.upload').click

      expect(page).to have_css('#revenue_upload_modal')

      page.execute_script <<-JS
        fakeFileInput = window.$('<input/>').attr({ id: 'fakeFileInput', type: 'file' }).appendTo('body');
      JS

      page.attach_file('fakeFileInput', "#{Rails.root}/tmp/good.csv")

      page.execute_script <<-JS
        var scope = angular.element('#browse').scope();
        scope.upload([fakeFileInput.get(0).files[0]]);
      JS

      find_button('Done').trigger('click')

      expect(page).to have_no_css('#revenue_upload_modal')

      within 'table tbody' do
        expect(page).to have_css('tr', count: 1)
      end
    end
  end

  describe 'uploading a bad csv' do
    before do
      File.open("#{Rails.root}/tmp/missing_required.csv", 'w+') { |f| f.write("#{missing_required_csv(client, user, product)}") }
      login_as user, scope: :user
      visit '/revenue'
      expect(page).to have_css('#revenue')
    end

    scenario 'shows an error message', js: true do
      find('.upload').click

      expect(page).to have_css('#revenue_upload_modal')

      page.execute_script <<-JS
        fakeFileInput = window.$('<input/>').attr({ id: 'fakeFileInput', type: 'file' }).appendTo('body');
      JS

      page.attach_file('fakeFileInput', "#{Rails.root}/tmp/missing_required.csv")

      page.execute_script <<-JS
        var scope = angular.element('#browse').scope();
        scope.upload([fakeFileInput.get(0).files[0]]);
      JS

      within '#revenue_upload_modal' do
        expect(page).to have_css('.progress-bar', visible: true)
        expect(page).to have_css('.alert.alert-danger')

        within '.alert' do
          expect(page).to have_text('Row 1 contains errors: ')
        end
      end
    end
  end
end
