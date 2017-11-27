require 'rails_helper'

feature 'Dashboard' do
  let(:company) { create :company, time_periods: [time_period, next_time_period] }
  let(:user) { create :user, company: company }
  let!(:parent) { create :parent_team, leader: user, company: company }
  let(:child) { create :child_team, parent: parent, company: company }
  let(:stage) { create :stage, probability: 100, company: company }
  let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31", company: company  }
  let!(:member) { create :user, team: child, company: company }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let(:deal_product) { create(:deal_product, deal: deal, open: true) }
  let!(:deal_product_budget) { create :deal_product_budget, deal_product: deal_product, budget: 200000, start_date: "2015-01-01", end_date: "2015-01-31" }

  describe 'as a leader' do
    let!(:quota) { create :quota, user: user, value: 20000, time_period: time_period, company: company }

    before do
      login_as user, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:closest_quarter).and_return(time_period)
      visit '/'
      wait_for_ajax 1
      expect(page).to have_css('#dashboard')
    end

    it 'shows the stats box and open deals', js: true do
      within '#stats' do
        expect(page.all('.stats-col .title')[1].text).to eq '$20K' # Quota
        expect(page.all('.stats-col .title')[2].text).to eq '$0' # Forecast
      end
    end
  end

  describe 'as a non-leader (member)' do
    let!(:quota) { create :quota, user: member, value: 20000, time_period: time_period, company: company }

    before do
      login_as member, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:closest_quarter).and_return(time_period)
      visit '/'
      wait_for_ajax 1
      expect(page).to have_css('#dashboard')
    end

    it 'shows the stats box and open deals', js: true do
      within '#stats' do
        expect(page.all('.stats-col .title')[1].text).to eq '$20K' # Quota
        expect(page.all('.stats-col .title')[2].text).to eq '$0' # Forecast
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
      allow_any_instance_of(Api::DashboardsController).to receive(:closest_quarter).and_return(time_period)
      visit '/dashboard'
      expect(page).to have_css('#dashboard')
    end

    it 'lists the reminders', js: true do
      within '#reminders' do
        expect(page).to have_css('.reminder-item', count: 3)
      end
    end
  end

  private

  def time_period
    @_time_period ||= create :time_period,
                             name: 'Q3',
                             period_type: 'quarter',
                             start_date: '2017-06-01',
                             end_date: '2017-09-30'
  end

  def next_time_period
    @_next_time_period ||= create :time_period,
                                  name: 'Q4',
                                  period_type: 'quarter',
                                  start_date: '2017-10-01',
                                  end_date: '2017-12-31'
  end
end
