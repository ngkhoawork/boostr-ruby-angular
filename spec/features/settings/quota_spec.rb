require 'rails_helper'

feature 'Quotas' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:q1) { create :time_period, company: company }
  let!(:q2) { create :time_period, company: company, start_date: q1.end_date + 1.month, end_date: q1.end_date + 2.months }
  let!(:quota_one) { create :quota, company: company, time_period: q1, user: user }
  let!(:quota_two) { create :quota, company: company, time_period: q2, user: user }

  describe 'editing quotas' do
    before do
      login_as user, scope: :user
      visit '/settings/quotas'
      expect(page).to have_css('#quotas')
    end

    scenario 'can edit a quota value inline and add a user', js: true do
      within '.quota-period' do
        expect(page).to have_text q1.name
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'td:last-child' do
          expect(page).to have_text '$10,000'
          find('span').trigger('click')

          fill_in 'quota-value', with: '20000'
          find('input').native.send_keys(:Enter)
          expect(page).to have_text '$20,000'
        end
      end

      within '.quota-period' do
        find('a').trigger('click')

        within('.dropdown-menu') do
          find('li:last-child a').trigger('click')
        end

        expect(page).to have_text q2.name
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'td:last-child' do
          expect(page).to have_text '$10,000'
        end
      end

      new_user = create :user, company: company

      within '#nav' do
        find('a.add-user').trigger('click')
      end

      expect(page).to have_css '#user_quota_modal'

      within '#user_quota_modal' do
        ui_select('quota_period', q2.name)
        ui_select('user', new_user.name)
        fill_in 'value', with: '20000'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css '#user_quota_modal'
      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)

        within 'tr:last-child td:last-child' do
          expect(page).to have_text '$20,000'
        end
      end
    end
  end
end
