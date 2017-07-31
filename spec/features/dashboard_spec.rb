require 'rails_helper'

feature 'Dashboard' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let!(:parent) { create :parent_team, leader: user }
  let!(:time_period) { create :time_period }
  let!(:child) { create :child_team, parent: parent }
  let(:stage) { create :stage, probability: 100 }
  let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
  let(:member) { create :user, team: child }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let(:deal_product) { create(:deal_product, deal: deal, open: true) }
  let!(:deal_product_budget) { create :deal_product_budget, deal_product: deal_product, budget: 200000, start_date: "2015-01-01", end_date: "2015-01-31" }

  describe 'as a leader' do
    let!(:quota) { create :quota, user: user, value: 20000, time_period: time_period }

    before do
      login_as user, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:time_period).and_return(time_period)
      visit '/'
      expect(page).to have_css('#dashboard')
    end

    scenario 'shows the stats box and open deals', js: true do
      within '#stats' do
        wait_for_ajax 1

        expect(page.all('.stats-col .title')[1].text).to eq '$20K' # Quota
        expect(page.all('.stats-col .title')[2].text).to eq '$964.4K' # Forecast
      end
    end
  end

  describe 'as a non-leader (member)' do
    let!(:quota) { create :quota, user: member, value: 20000, time_period: time_period }

    before do
      login_as member, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:time_period).and_return(time_period)
      visit '/'
      expect(page).to have_css('#dashboard')
    end

    scenario 'shows the stats box and open deals', js: true do
      within '#stats' do
        wait_for_ajax 1

        expect(page.all('.stats-col .title')[1].text).to eq '$20K' # Quota
        expect(page.all('.stats-col .title')[2].text).to eq '$964.4K' # Forecast
      end

      within '#open-deals' do
        expect(page).to have_css '.deals-table'

        within 'table tbody' do
          expect(page).to have_css 'tr', count: 1
        end
      end
    end
  end

  describe 'reminder list' do
    let!(:quota) { create :quota, user: user, value: 20000, time_period: time_period }
    let(:client) { create :client, created_by: user.id }
    let(:contact) { create :contact, company: company, clients: [client] }
    let!(:deal_reminder) { create(:reminder, user_id: user.id, remindable_id: deal.id, remindable_type: 'Deal') }
    let!(:client_reminder) { create(:reminder, user_id: user.id, remindable_id: client.id, remindable_type: 'Client') }
    let!(:contact_reminder) { create(:reminder, user_id: user.id, remindable_id: contact.id, remindable_type: 'Contact') }

    before do
      login_as user, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:time_period).and_return(time_period)
      visit '/dashboard'
      expect(page).to have_css('#dashboard')
    end

    scenario 'lists the reminders', js: true do
      within '#reminders' do
        expect(page).to have_css('.reminder-item', count: 3)
      end
    end
  end
end
