require 'rails_helper'

describe Deal do
  let(:company) { create :company }
  let(:user) { create :user }

  context 'associations' do
    it { should have_many(:contacts).through(:deal_contacts) }
    it { should have_many(:deal_contacts) }
    it { should have_many(:requests) }

    context 'restrictions' do
      let!(:deal) { create :deal }
      let!(:deal_product) { create :deal_product, deal: deal, budget: 100_000 }
      let(:closed_won_stage) { create :closed_won_stage }

      it 'restricts deleting deal with IO' do
        deal.update(stage: closed_won_stage)

        expect{deal.destroy}.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  context 'scopes' do

    context 'for_client' do
      let!(:deal) { create :deal }
      let(:agency) { create :client }
      let!(:another_deal) { create :deal, agency: agency }

      it 'returns all when client_id is nil' do
        expect(Deal.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Deal.for_client(agency.id).count).to eq(1)
      end
    end

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31' }
      let!(:in_deal) { create :deal, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal) { create :deal, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'should return deals that are completely in the time period' do
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date)).to include(in_deal)
      end

      it 'returns deals that are partially in the time period' do
        create :deal, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end

    context 'open' do
      let(:closed_stage) { create :stage, open: false }
      let(:open_stage) { create :stage, open: true }
      let!(:open_deal) { create :deal, stage: open_stage }
      let!(:closed_deal) { create :deal, stage: closed_stage }

      it 'returns only deals that have an open stage' do
        expect(Deal.all.length).to eq(2)
        expect(Deal.open.length).to eq(1)
        expect(Deal.open).to include(open_deal)
      end
    end
  end

  context 'validations' do
    let!(:deal) { create :deal }

    context 'billing contact' do
      let(:validation) { deal.company.validation_for(:billing_contact) }

      it 'passes validation if company does not have it' do
        expect(deal).to be_valid
      end

      context 'validation active' do
        before do
          validation.create_criterion
        end

        it 'passes validation if stage is less then criterion' do
          validation.criterion.update(value: 50)
          expect(deal).to be_valid
        end

        it 'passes validation if deal has a valid billing contact' do
          validation.criterion.update(value: 10)
          create :billing_deal_contact, deal: deal
          expect(deal).to be_valid
        end

        it 'fails validation when deal does not have a billing contact' do
          validation.criterion.update(value: 10)
          expect(deal).not_to be_valid
        end

        it 'fails validation when deal has more than one billing contact' do
          validation.criterion.update(value: 10)
          create :billing_deal_contact, deal: deal

          expect{
            create :billing_deal_contact, deal: deal
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'account manager' do
      let(:validation) { deal.company.validation_for(:account_manager) }
      let!(:deal_member) { create :deal_member, deal: deal }

      it 'passes validation if company does not have it' do
        expect(deal).to be_valid
      end

      context 'validation active' do
        before do
          validation.create_criterion
        end

        it 'passes validation if stage is less then criterion' do
          validation.criterion.update(value: 50)
          expect(deal).to be_valid
        end

        it 'fails validation when deal does not have deal members' do
          deal.deal_members.destroy_all
          validation.criterion.update(value: 10)
          expect(deal).not_to be_valid
        end

        it 'fails validation when deal member is not an account manager' do
          validation.criterion.update(value: 10)
          expect(deal).not_to be_valid
        end

        it 'passes validation if deal has an account manager' do
          validation.criterion.update(value: 10)
          deal_member.user.update(user_type: ACCOUNT_MANAGER)
          expect(deal).to be_valid
        end
      end
    end

    context 'disable deal closed won' do
      let(:validation) { deal.company.validation_for(:disable_deal_won) }
      let(:closed_won_stage) { create :closed_won_stage }

      it 'passes validation if company does not have it' do
        deal.update(stage: closed_won_stage)

        expect(deal).to be_valid
        expect(deal.reload.stage).to eq closed_won_stage
      end

      it 'passes validation if it is off' do
        validation.criterion.update(value: false)

        deal.assign_attributes(stage: closed_won_stage)

        expect(deal).to be_valid
      end

      it 'passes validation in default context' do
        validation.criterion.update(value: true)

        deal.assign_attributes(stage: closed_won_stage)

        expect(deal).to be_valid
      end

      it 'is invalid if validation is active' do
        validation.criterion.update(value: true)

        deal.assign_attributes(stage: closed_won_stage)

        expect(deal).not_to be_valid(:manual_update)
        expect(deal.errors.full_messages).to eql [
          'Stage Deals can\'t be updated to Closed Won manually. '\
          'Deals can only be set to Closed Won from API integration'
        ]
      end

      it 'does not save record when validation is active' do
        validation.criterion.update(value: true)

        deal.assign_attributes(stage: closed_won_stage)

        expect(deal.save(context: :manual_update)).to be false
      end

      it 'passes validation if stage is not 100/won' do
        validation.criterion.update(value: true)

        deal.assign_attributes(stage: closed_won_stage)
        deal.save
        deal.reload.assign_attributes(stage: deal.previous_stage)

        expect(deal).to be_valid(:manual_update)
      end
    end

    describe '"Restrict deal reopen" validation' do
      let(:company) { deal.company }
      let(:validation) { company.validations.find_or_create_by(factor: 'Restrict Deal Reopen', value_type: 'Boolean') }

      before { deal.update_columns(stage_id: closed_won_stage.id) }

      subject { deal.update(stage: discuss_stage, modifying_user: modifying_user) }

      context 'when a validation was set to true' do
        before(:each) { validation.criterion.update(value: true) }

        context 'and when modifying_user is "user"' do
          let(:modifying_user) { user }

          it { expect{subject}.to change{ deal.errors[:stage] }.from([]).to(['Only admins are allowed to re-open deals']) }
        end

        context 'and when modifying_user is "admin"' do
          let(:modifying_user) { admin }

          it { expect{subject}.not_to change{ deal.errors[:stage] } }
        end
      end

      context 'when a validation was set to false' do
        before(:each) { validation.criterion.update(value: false) }

        context 'and when modifying_user is "user"' do
          let(:modifying_user) { user }

          it { expect{subject}.not_to change{ deal.errors[:stage] } }
        end

        context 'and when modifying_user is "admin"' do
          let(:modifying_user) { admin }

          it { expect{subject}.not_to change{ deal.errors[:stage] } }
        end
      end
    end
  end

  describe '#has_billing_contact?' do
    let!(:deal) { create :deal }
    let!(:deal_contact) { create :deal_contact, deal: deal }

    it 'returns true if deal has a valid billing contact' do
      deal_contact.update(role: 'Billing')
      expect(deal.has_billing_contact?).to be true
    end

    it 'returns false if no billing contact found' do
      expect(deal.has_billing_contact?).to be false
    end
  end

  describe '#no_more_one_billing_contact?' do
    let!(:deal) { create :deal }

    it 'is true if deal has no billing contacts' do
      expect(deal.no_more_one_billing_contact?).to be true
    end

    it 'is true if deal has one billing contact' do
      create :deal_contact, deal: deal, role: 'Billing'
      expect(deal.no_more_one_billing_contact?).to be true
    end
  end

  describe '#integrate_with_operative' do
    let!(:deal) { create :deal }
    let(:discuss_stage) { create :discuss_stage }
    let(:proposal_stage) { create :proposal_stage }
    let(:lost_stage) { create :lost_stage }
    let!(:api_configuration) { create :operative_api_configuration, trigger_on_deal_percentage: 25 }

    it 'integrates if stage equals threshold' do
      allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

      expect(OperativeIntegrationWorker).to receive(:perform_async).with(deal.id)

      deal.update(stage: discuss_stage)
    end

    it 'integrates when stage is above threshold' do
      allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

      expect(OperativeIntegrationWorker).to receive(:perform_async).with(deal.id)

      deal.update(stage: proposal_stage)
    end

    it 'integrates when there was an integration and config requires to reintegrate each stage' do
      api_configuration.update(recurring: true)
      create :integration, integratable: deal, external_type: Integration::OPERATIVE, external_id: 10

      allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

      expect(OperativeIntegrationWorker).to receive(:perform_async).with(deal.id)

      deal.update(stage: proposal_stage)
    end

    it 'integrates when stage is lost and there was an integration already' do
      create :integration, integratable: deal, external_type: Integration::OPERATIVE, external_id: 10

      allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

      expect(OperativeIntegrationWorker).to receive(:perform_async).with(deal.id)

      deal.update(stage: lost_stage)
    end

    context 'no integration' do
      it 'when stage is not changed' do
        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(name: 'Christmas Auction')
      end

      it 'when stage is below threshold' do
        api_configuration.update(trigger_on_deal_percentage: 75)

        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: discuss_stage)
      end

      it 'when stage is below threshold and integration is recurring' do
        api_configuration.update(trigger_on_deal_percentage: 75, recurring: true)

        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: discuss_stage)
      end

      it 'when there was an integration already' do
        create :integration, integratable: deal, external_type: Integration::OPERATIVE, external_id: 10

        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: proposal_stage)
      end

      it 'when stage is lost but there was no integration' do
        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: lost_stage)
      end

      it 'when company is not allowed to run operative' do
        allow(deal).to receive(:company_allowed_use_operative?).and_return(false)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: proposal_stage)
      end

      it 'when operative integration config is missing' do
        api_configuration.destroy

        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: proposal_stage)
      end

      it 'when operative integration config is turted off' do
        api_configuration.update(switched_on: false)

        allow(deal).to receive(:company_allowed_use_operative?).and_return(true)

        expect(OperativeIntegrationWorker).not_to receive(:perform_async).with(deal.id)

        deal.update(stage: proposal_stage)
      end
    end

  end

  describe '#has_account_manager_member?' do
    let!(:deal) { create :deal }
    let!(:deal_member) { create :deal_member, deal: deal }

    it 'returns true if deal has an account manager member' do
      deal_member.user.update(user_type: ACCOUNT_MANAGER)
      expect(deal.has_account_manager_member?).to be true
    end

    it 'returns false if deal does not have members' do
      deal.deal_members.destroy_all
      expect(deal.has_account_manager_member?).to be false
    end

    it 'returns false if deal member is not an account manager' do
      expect(deal.has_account_manager_member?).to be false
    end
  end

  describe '#in_period_amt' do
    let(:deal) { create :deal }
    let(:product) { create :product }
    let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-01-31' }

    it 'returns 0 when there are no deal products' do
      expect(deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(0)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      single_month_deal = create :deal, start_date: '2015-01-01', end_date: '2015-01-31'
      create :deal_product, deal: single_month_deal, product: product, budget: 1000

      expect(single_month_deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(1000)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      two_month_deal = create :deal, start_date: '2015-01-27', end_date: '2015-02-05'
      create :deal_product, deal: two_month_deal, product: product, budget: 1000

      expect(two_month_deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(500)
    end
  end

  describe '#days' do
    let(:deal) { create :deal, start_date: Date.new(2015, 1, 1), end_date: Date.new(2015, 1, 31) }

    it 'returns the number of days between the start and end dates.' do
      expect(deal.days).to eq(31)
    end
  end

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28) }

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#days_per_month' do
    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expect(deal.days_per_month).to eq([6, 31, 30, 28])
    end

    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([17, 30])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([6])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 10, 15)
      expect(deal.days_per_month).to eq([6, 15])
    end
  end

  describe '#reset_products' do
    let!(:deal) { create :deal }
    let!(:product) { create :product }
    let!(:deal_product) { create :deal_product, deal: deal, product: product }

    it 'deletes and recreates deal_product_budgets based on the start or end date changing' do
      expect do
        deal.update_attributes(end_date: Date.new(2015, 9, 29))
      end.to change(DealProductBudget, :count).by(1)
    end
  end

  describe '#generate_deal_members' do
    let(:client) { create :client }
    let!(:client_role_owner) { create :option, field: client_role_field(company), name: "Owner" }
    let(:role) { create :value, field: client_role_field(company), option: client_role_owner }
    let!(:client_member) { create :client_member, user: user, client: client, values: [role] }
    let(:deal) { build :deal, advertiser: client, company: company }

    xit 'creates deal_members with defaults when creating a deal' do
      expect do
        deal.save
      end.to change(DealMember, :count).by(1)
      expect(DealMember.first.deal_id).to eq(deal.id)
      expect(DealMember.first.user_id).to eq(client_member.user_id)
      expect(DealMember.first.values.first.option_id).to eq(role.option_id)
      expect(DealMember.first.share).to eq(client_member.share)
    end

    context 'when there are no client members' do
      let!(:client_wo_members) { create :client }
      let!(:deal) { build :deal, advertiser: client_wo_members, creator: user, company: company }

      it 'assigns 100 percent share to the deal creator' do
        expect do
          deal.save
        end.to change(DealMember, :count).by(1)
        expect(deal.deal_members.count).to be(1)
        expect(deal.deal_members.first.user_id).to be(user.id)
        expect(deal.deal_members.first.share).to be(100)
      end
    end
  end

  context 'to_zip' do
    it 'returns the contents of deal zip' do
      deal.deal_products.create(product_id: product.id, budget: 10_000)
      deal_zip = Deal.to_zip
      expect(deal_zip).not_to be_nil
    end
  end

  describe 'to_csv' do
    it 'returns the contents of deal zip' do
      company.deals << deal

      csv = Deal.to_csv(company.deals, company)

      expect(csv).not_to be_nil
      expect(csv).to include 'Created By'
      expect(csv).to include deal.creator.email
      expect(csv).to include deal.id.to_s
    end
  end

  describe '#import' do
    let!(:user) { create :user }
    let!(:another_user) { create :user }
    let!(:company) { user.company }
    let!(:stage_won) { create :stage, company: user.company, name: 'Won', probability: 100, open: false }
    let!(:stage_lost) { create :stage, company: user.company, name: 'Lost', probability: 0, open: false }
    let!(:advertiser) { create :client, created_by: user.id, client_type_id: advertiser_type_id(company) }
    let!(:agency) { create :client, created_by: user.id, client_type_id: agency_type_id(company) }
    let!(:deal_type_field) { user.company.fields.find_by_name('Deal Type') }
    let!(:deal_type) { create :option, field: deal_type_field, company: user.company }
    let!(:deal_source_field) { user.company.fields.find_by_name('Deal Source') }
    let!(:deal_source) { create :option, field: deal_source_field, company: user.company }
    let!(:close_reason_field) { user.company.fields.find_by_name('Close Reason') }
    let!(:close_reason) { create :option, field: close_reason_field, company: user.company }
    let!(:existing_deal) { create :deal, creator: another_user, updator: another_user }
    let!(:contacts) { create_list :contact, 4, company: company, client_id: advertiser.id }
    let(:import_log) { CsvImportLog.last }

    it 'creates a new deal from csv' do
      data = build :deal_csv_data, stage: stage_won.name
      expect do
        Deal.import(generate_csv(data), user.id, 'deals.csv')
      end.to change(Deal, :count).by(1)

      deal = Deal.last
      expect(deal.name).to eq(data[:name])
      expect(deal.advertiser.name).to eq(data[:advertiser])
      expect(deal.agency.name).to eq(data[:agency])
      expect(deal.curr_cd).to eq(data[:curr_cd])
      expect(deal.creator.email).to eq(user.email)
      expect(deal.updator.email).to eq(user.email)
      expect(deal.start_date).to eq(Date.strptime(data[:start_date], '%m/%d/%Y'))
      expect(deal.end_date).to eq(Date.strptime(data[:end_date], '%m/%d/%Y'))
      expect(deal.stage.name).to eq(data[:stage])
      expect(deal.users.map(&:email)).to eq([data[:team].split('/')[0]])
      expect(deal.deal_members.map(&:share)).to eq([data[:team].split('/')[1].to_i])
      expect(deal.created_at).to eq(DateTime.strptime(data[:created], '%m/%d/%Y') + 8.hours)
      expect(deal.closed_at).to eq(DateTime.strptime(data[:closed_date], '%m/%d/%Y') + 8.hours)
      expect(deal.contacts.map(&:address).map(&:email).sort).to eq(data[:contacts].split(';').sort)
    end

    it 'creates a deal with type and source' do
      data = build :deal_csv_data, type: deal_type.name, source: deal_source.name
      Deal.import(generate_csv(data), user.id, 'deals.csv')
      deal = Deal.last

      expect(deal.values.where(field: deal_type_field).first.option_id).to eq deal_type.id
      expect(deal.values.where(field: deal_source_field).first.option_id).to eq deal_source.id
    end

    it 'updates a deal by an ID match' do
      data = build :deal_csv_data, id: existing_deal.id
      expect do
        Deal.import(generate_csv(data), user.id, 'deals.csv')
      end.not_to change(Deal, :count)
      existing_deal.reload

      expect(existing_deal.name).to eq(data[:name])
      expect(existing_deal.advertiser.name).to eq(data[:advertiser])
      expect(existing_deal.agency.name).to eq(data[:agency])
      expect(existing_deal.creator.email).not_to eq(user.email)
      expect(existing_deal.updator.email).to eq(user.email)
      expect(existing_deal.start_date).to eq(Date.parse(data[:start_date]))
      expect(existing_deal.end_date).to eq(Date.parse(data[:end_date]))
      expect(existing_deal.stage.name).to eq(data[:stage])
      expect(existing_deal.users.map(&:email)).to include(data[:team].split('/')[0])
      expect(existing_deal.deal_members.map(&:share)).to include(data[:team].split('/')[1].to_i)
      expect(existing_deal.contacts.map(&:address).map(&:email).sort).to eq(data[:contacts].split(';').sort)
    end

    context 'csv import log' do
      it 'creates csv import log' do
        data = build :deal_csv_data

        expect do
          Deal.import(generate_csv(data), user.id, 'deals.csv')
        end.to change(CsvImportLog, :count).by(1)
      end

      it 'saves amount of processed rows for new objects' do
        data = build :deal_csv_data

        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
        expect(import_log.file_source).to eq 'deals.csv'
      end

      it 'saves amount of processed rows when updating existing objects' do
        data = build :deal_csv_data, id: existing_deal.id

        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_imported).to be 1
      end

      it 'counts failed rows' do
        no_name = build :deal_csv_data, name: nil
        Deal.import(generate_csv(no_name), user.id, 'deals.csv')

        expect(import_log.rows_processed).to be 1
        expect(import_log.rows_failed).to be 1
      end
    end

    it 'sets closed_at date for existing deals' do
      data = build :deal_csv_data, id: existing_deal.id, stage: existing_deal.stage.name
      Deal.import(generate_csv(data), user.id, 'deals.csv')

      existing_deal.reload
      expect(existing_deal.closed_at).to eq(DateTime.strptime(data[:closed_date], '%m/%d/%Y') + 8.hours)
    end

    it 'creates a deal with close reason' do
      data = build :deal_csv_data, close_reason: close_reason.name, loss_comments: 'Can retry later'
      Deal.import(generate_csv(data), user.id, 'deals.csv')
      deal = Deal.last

      expect(deal.values.where(field: close_reason_field).first.option_id).to eq close_reason.id
      expect(deal.closed_reason_text).to eq 'Can retry later'
    end

    it 'creates a deal with created by email' do
      company.users << create(:user, email: 'creator_email@gmail.com')
      another_company_user = company.users.where(email: 'creator_email@gmail.com').first
      data = build :deal_csv_data, created_by: another_company_user.email

      Deal.import(generate_csv(data), user.id, 'deals.csv')
      deal = Deal.last

      expect(deal.created_by).to_not eq user.id
      expect(deal.created_by).to eq another_company_user.id
    end

    it 'finds a deal by name match' do
      data = build :deal_csv_data, name: existing_deal.name
      expect do
        Deal.import(generate_csv(data), user.id, 'deals.csv')
      end.not_to change(Deal, :count)
      existing_deal.reload

      expect(existing_deal.updator.email).to eq(user.email)
      expect(existing_deal.start_date).to eq(Date.parse(data[:start_date]))
      expect(existing_deal.end_date).to eq(Date.parse(data[:end_date]))
    end

    it 'replaces deal team when flag is set' do
      new_user = create :user, company: existing_deal.company
      data = build :deal_csv_data, name: existing_deal.name, replace_team: 'Y', team: new_user.email + '/100'
      Deal.import(generate_csv(data), user.id, 'deals.csv')

      existing_deal.reload

      expect(existing_deal.users.map(&:email)).to eq([new_user.email])
    end

    context 'invalid data' do
      let!(:duplicate_advertiser) { create :client, client_type_id: advertiser_type_id(user.company), company: company }
      let!(:duplicate_advertiser2) { create :client, client_type_id: advertiser_type_id(user.company), company: company, name: duplicate_advertiser.name }
      let!(:duplicate_agency) { create :client, client_type_id: agency_type_id(user.company), company: company }
      let!(:duplicate_agency2) { create :client, client_type_id: agency_type_id(user.company), company: company, name: duplicate_agency.name }
      let!(:duplicate_deal) { create :deal, name: existing_deal.name }

      it 'requires ID to match' do
        data = build :deal_csv_data, id: 0
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal ID #{data[:id]} could not be found"] }]
        )
      end

      it 'requires name to exist' do
        data = build :deal_csv_data, name: nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal name can't be blank"] }]
        )
      end

      it 'requires name to match no more than one deal' do
        data = build :deal_csv_data, name: duplicate_deal.name
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal name #{data[:name]} matched more than one deal record"] }]
        )
      end

      it 'requires advertiser to be present' do
        data = build :deal_csv_data
        data[:advertiser] = nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Advertiser can't be blank"] }]
        )
      end

      it 'requires advertiser to exist' do
        data = build :deal_csv_data, advertiser: 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Advertiser #{data[:advertiser]} could not be found"] }]
        )
      end

      it 'requires advertiser to match no more than 1 record' do
        data = build :deal_csv_data, advertiser: duplicate_advertiser2.name
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Advertiser #{data[:advertiser]} matched more than one account record"] }]
        )
      end

      it 'requires agency to exist' do
        data = build :deal_csv_data, agency: 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Agency #{data[:agency]} could not be found"] }]
        )
      end

      it 'requires agency to match no more than 1 record' do
        data = build :deal_csv_data, agency: duplicate_agency2.name
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Agency #{data[:agency]} matched more than one account record"] }]
        )
      end

      it 'requires currency code to be present' do
        data = build :deal_csv_data
        data[:curr_cd] = nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Currency code can't be blank"] }]
        )
      end

      it 'requires currency code to exist' do
        data = build :deal_csv_data
        data[:curr_cd] = 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Currency N/A is not found"] }]
        )
      end

      it 'requires deal type to exist' do
        data = build :deal_csv_data, type: 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Type #{data[:type]} could not be found"] }]
        )
      end

      it 'requires deal source to exist' do
        data = build :deal_csv_data, source: 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Source #{data[:source]} could not be found"] }]
        )
      end

      it 'requires start date to be valid' do
        data = build :deal_csv_data, start_date: 'zzz'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['Start Date must have valid date format MM/DD/YYYY'] }]
        )
      end

      it 'requires end date to be valid' do
        data = build :deal_csv_data, end_date: 'zzz'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['End Date must have valid date format MM/DD/YYYY'] }]
        )
      end

      it 'requires start date to be present if end date is set' do
        data = build :deal_csv_data, start_date: nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['Start Date must be present if End Date is set'] }]
        )
      end

      it 'requires end date to be present if start date is set' do
        data = build :deal_csv_data, end_date: nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['End Date must be present if Start Date is set'] }]
        )
      end

      it 'requires start date to preceed end date' do
        data = build :deal_csv_data, start_date: '12/12/2016', end_date: '11/11/2016'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ['Start Date must preceed End Date'] }]
        )
      end

      it 'requires stage to be present' do
        data = build :deal_csv_data
        data[:stage] = nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Stage can't be blank"] }]
        )
      end

      it 'requires stage to exist' do
        data = build :deal_csv_data, stage: 'N/A'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Stage #{data[:stage]} could not be found"] }]
        )
      end

      it 'requires deal team to be present' do
        data = build :deal_csv_data
        data[:team] = nil
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Team can't be blank"] }]
        )
      end

      it 'requires deal team members to exist' do
        data = build :deal_csv_data, team: 'NA/0'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Member #{data[:team].split('/')[0]} could not be found in the User list"] }]
        )
      end

      it 'requires deal team member to have a share' do
        data = build :deal_csv_data, team: 'NA'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Member #{data[:team].split('/')[0]} does not have a share"] }]
        )
      end

      it 'requires created date to be a valid date' do
        data = build :deal_csv_data, created: 'NA'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Creation Date must have valid date format MM/DD/YYYY"] }]
        )
      end

      it 'requires closed date to be a valid date' do
        data = build :deal_csv_data, closed_date: 'NA'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Deal Close Date must have valid date format MM/DD/YYYY"] }]
        )
      end

      it 'requires company close reason to exist' do
        data = build :deal_csv_data, close_reason: 'NA'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Close Reason #{data[:close_reason]} could not be found"] }]
        )
      end

      it 'requires company contacts to exist' do
        data = build :deal_csv_data, contacts: 'NA'
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Contact #{data[:contacts]} could not be found"] }]
        )
      end

      it 'created by email not found' do
        created_by_email = "zzz@gmail.com"
        data = build :deal_csv_data, created_by: "zzz@gmail.com"
        Deal.import(generate_csv(data), user.id, 'deals.csv')

        expect(import_log.rows_failed).to be 1
        expect(import_log.error_messages).to eq(
          [{ "row" => 1, "message" => ["Created By #{created_by_email} user could not be found"] }]
        )
      end
    end

    context 'deal custom fields' do
      it 'imports deal custom field' do
        setup_custom_fields(company)
        data = build :deal_csv_data_custom_fields,
               stage: stage_won.name,
               custom_field_names: company.deal_custom_field_names

        expect do
          Deal.import(generate_csv(data), user.id, 'deals.csv')
        end.to change(DealCustomField, :count).by(1)

        deal_cf = DealCustomField.last

        expect(deal_cf.datetime1).to eq(data[:production_date])
        expect(deal_cf.boolean1).to eq(data[:risky_click])
        expect(deal_cf.number1.to_f).to eq(data[:target_views])
        expect(deal_cf.text1).to eq(data[:deal_type])
      end
    end
  end

  context 'after_create' do
    context 'connect_deal_clients' do
      it 'does not create a connection without agency' do
        expect do
          deal(advertiser: advertiser, agency: nil)
        end.not_to change(ClientConnection, :count)
      end

      it 'links advertiser and agency' do
        expect do
          deal(agency_id: agency.id, advertiser_id: advertiser.id)
        end.to change(ClientConnection, :count).by 1

        cl_conn = ClientConnection.find_by(agency_id: agency.id, advertiser_id: advertiser.id)

        expect(cl_conn).to be_present
      end

      it 'does not duplicate the connection' do
        client_connection(agency, advertiser)

        deal(agency_id: agency.id, advertiser_id: advertiser.id)

        cl_conns = ClientConnection.where(agency_id: agency.id, advertiser_id: advertiser.id)

        expect(cl_conns.count).to be 1
      end
    end
  end

  context 'after_update' do
    it 'create deal_steage_log' do
      stage = create :stage
      stage1 = create :stage

      deal(stage: stage, updator: user, stage_updator: user, stage_updated_at: Date.new)

      deal.update_attributes(stage: stage1)
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'U')).not_to be_nil
    end

    context 'connect_deal_clients' do
      it 'does not create a connection without agency' do
        deal(advertiser: advertiser, agency: nil)

        expect do
          deal.update(agency: nil)
        end.not_to change(ClientConnection, :count)
      end

      it 'links advertiser and agency' do
        deal(advertiser_id: advertiser.id)

        expect do
          deal.update(agency_id: agency.id)
        end.to change(ClientConnection, :count).by 1

        cl_conn = ClientConnection.find_by(agency_id: agency.id, advertiser_id: advertiser.id)

        expect(cl_conn).to be_present
      end

      it 'does not duplicate the connection' do
        client_connection(agency, advertiser)

        deal(advertiser_id: advertiser.id)
        deal.update(agency_id: agency.id)

        cl_conns = ClientConnection.where(agency_id: agency.id, advertiser_id: advertiser.id)

        expect(cl_conns.count).to be 1
      end
    end
  end

  context 'after_destroy' do
    let(:user) { create :user }
    let(:stage) { create :stage }
    let(:deal) { create :deal, stage: stage, creator: user, updator: user, stage_updator: user, stage_updated_at: Date.new }
    it 'create deal_steage_log' do
      deal.destroy
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'D')).not_to be_nil
    end
  end

  context 'before_create' do
    let(:won_stage) { create :stage, probability: 100, open: false }
    let(:lost_stage) { create :stage, probability: 0, open: false }
    let(:open_stage) { create :stage }

    it 'when create deal with closed won stage set closed_at date as created_at' do
      deal = build(
        :deal,
        stage: won_stage,
        creator: user,
        updator: user,
        stage_updator: user,
        stage_updated_at: Date.new,
        company: company
      )

      deal.save!

      expect(deal.closed_at).to eq deal.created_at
    end

    it 'when create deal with closed lost stage set closed_at date as created_at' do
      deal = build(
          :deal,
          stage: lost_stage,
          creator: user,
          updator: user,
          stage_updator: user,
          stage_updated_at: Date.new,
          company: company
      )

      deal.save!

      expect(deal.closed_at).to eq deal.created_at
    end

    it 'has not closed_at when create not open deal' do
      deal = build(
        :deal,
        stage: open_stage,
        creator: user,
        updator: user,
        stage_updator: user,
        stage_updated_at: Date.new,
        company: company
      )

      deal.save!

      expect(deal.closed_at).to be_nil
    end
  end

  describe 'before_update' do
    it 'should set closed_at date and not reset when user reopen deal' do
      deal.update(stage: closed_won_stage)
      deal.update_close
      deal_closed_at_date = deal.closed_at

      # reopen closed deal
      deal.update(stage: discuss_stage)
      deal.update_close

      expect(deal.closed_at).to_not be_nil
      expect(deal.closed_at).to eq deal_closed_at_date
    end

  end

  describe '#updated?' do
    let(:deal) { create :deal, creator: user, company: company }

    context 'if deal is new' do
      it { expect(deal.updated?).to be false }
    end

    context 'if deal was updated' do
      it do
        deal.assign_attributes(name: "new name", updated_at: 1.second.from_now)
        deal.save
        expect(deal.updated?).to be true
      end
    end
  end

  private

  def closed_won_stage
    @_closed_won_stage ||= create :closed_won_stage
  end

  def discuss_stage
    @_discuss_stage ||= create :discuss_stage
  end

  def deal(opts={})
    defaults = { company: company, creator: user }
    @_deal ||= create :deal, defaults.merge(opts)
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, budget: 100_000
  end

  def user
    @_user ||= create :user, company: company
  end

  def admin
    @_admin ||= create :admin, company: company
  end

  def product
    @_product ||= create :product
  end

  def company
    @_company ||= create :company
  end

  def advertiser(opts={})
    defaults = { company: company }
    @_advertiser ||= create :client, :advertiser, defaults.merge(opts)
  end

  def agency(opts={})
    defaults = { company: company }
    @_agency ||= create :client, :agency, defaults.merge(opts)
  end

  def client_connection(agency, advertiser)
    @_client_connection ||= create :client_connection, agency: agency, advertiser: advertiser
  end

  def setup_custom_fields(company)
    create :deal_custom_field_name, field_type: 'datetime', field_label: 'Production Date', company: company
    create :deal_custom_field_name, field_type: 'boolean',  field_label: 'Risky Click?', company: company
    create :deal_custom_field_name, field_type: 'number',   field_label: 'Target Views', company: company
    create :deal_custom_field_name, field_type: 'text',     field_label: 'Deal Type', company: company
  end
end
