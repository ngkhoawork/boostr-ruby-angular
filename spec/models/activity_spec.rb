require 'rails_helper'

RSpec.describe Activity, type: :model do
  let!(:company) { create :company }

  describe '#add_activity' do
    let(:client) { create :client }
    let(:deal) { create :deal, advertiser: client }
    let(:user) { create :user }
    let!(:activity_types) { create_list :activity_type, 5 }
    let(:activity) { create :activity, deal: deal, user: user, happened_at: Date.new(2016, 3, 31) }

    it 'return activity date' do
      expect(activity.happened_at).to eq(Date.new(2016, 3, 31))
    end

    describe '#import' do
      let!(:user) { create :user }
      let!(:advertiser) { create :client, created_by: user.id, client_type_id: advertiser_type_id(company) }
      let!(:agency) { create :client, created_by: user.id, client_type_id: agency_type_id(company) }
      let!(:deal) { create :deal, name: 'New Big Deal' }
      let!(:contacts) { create_list :contact, 4, company: company }
      let!(:activity) { create :activity }
      let(:import_log) { CsvImportLog.last }

      it 'creates a new activity from csv' do
        data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name
        expect do
          Activity.import(generate_csv(data), user.id, 'activity.csv')
        end.to change(Activity, :count).by(1)

        new_activity = Activity.last
        expect(new_activity.happened_at).to eq(data[:date])
        expect(new_activity.creator.email).to eq(data[:creator])
        expect(new_activity.updator.email).to eq(data[:creator])
        expect(new_activity.user.email).to eq(data[:creator])
        expect(new_activity.client.name).to eq(data[:advertiser])
        expect(new_activity.agency.name).to eq(data[:agency])
        expect(new_activity.deal.name).to eq(data[:deal])
        expect(new_activity.activity_type_name).to eq(data[:type])
        expect(new_activity.comment).to eq(data[:comment])
        expect(new_activity.contacts.map(&:address).map(&:email).sort).to eq(data[:contacts].split(';').sort)
      end

      it 'updates an existing activity by ID match' do
        data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name, id: activity.id
        expect do
          Activity.import(generate_csv(data), user.id, 'activities.csv')
        end.not_to change(Activity, :count)
        activity.reload

        expect(activity.id).to eq(data[:id])
        expect(activity.happened_at).to eq(data[:date])
        expect(activity.creator.email).to eq(data[:creator])
        expect(activity.updator.email).to eq(data[:creator])
        expect(activity.user.email).to eq(data[:creator])
        expect(activity.client.name).to eq(data[:advertiser])
        expect(activity.agency.name).to eq(data[:agency])
        expect(activity.deal.name).to eq(data[:deal])
        expect(activity.activity_type_name).to eq(data[:type])
        expect(activity.comment).to eq(data[:comment])
      end

      it 'adds new contacts to the existing ones' do
        activity_contacts = activity.contacts.map(&:address).map(&:email)
        data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name, id: activity.id
        Activity.import(generate_csv(data), user.id, 'activities.csv')
        activity.reload

        expected_contacts = (activity_contacts + data[:contacts].split(';')).sort
        expect(activity.contacts.map(&:address).map(&:email).sort).to eq(expected_contacts)
      end

      it 'correctly processes year in YY format' do
        data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name, id: activity.id, date: '10/11/17'
        Activity.import(generate_csv(data), user.id, 'activities.csv')
        activity.reload

        expect(activity.happened_at).to eq DateTime.parse('11/10/2017')
      end

      context 'csv import log' do
        it 'creates csv import log' do
          data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name

          expect do
            Activity.import(generate_csv(data), user.id, 'activities.csv')
          end.to change(CsvImportLog, :count).by(1)
        end

        it 'saves amount of processed rows for new objects' do
          data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name

          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_processed).to be 1
          expect(import_log.rows_imported).to be 1
          expect(import_log.file_source).to eq 'activities.csv'
        end

        it 'saves amount of processed rows when updating existing objects' do
          data = build :activity_csv_data, company: company, agency: agency.name, advertiser: advertiser.name, id: activity.id

          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_processed).to be 1
          expect(import_log.rows_imported).to be 1
        end

        it 'counts failed rows' do
          data = build :activity_csv_data, company: company, date: nil
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_processed).to be 1
          expect(import_log.rows_failed).to be 1
        end
      end

      context 'invalid data' do
        let!(:duplicate_advertiser) { create :client, client_type_id: advertiser_type_id(user.company), company: company }
        let!(:duplicate_advertiser2) { create :client, client_type_id: advertiser_type_id(user.company), company: company, name: duplicate_advertiser.name }
        let!(:duplicate_agency) { create :client, client_type_id: agency_type_id(user.company), company: company }
        let!(:duplicate_agency2) { create :client, client_type_id: agency_type_id(user.company), company: company, name: duplicate_agency.name }
        let!(:duplicate_deal) { create :deal, company: company }
        let!(:duplicate_deal2) { create :deal, company: company, name: duplicate_deal.name }

        it 'requires date to be present' do
          data = build :activity_csv_data, date: nil
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ['Date is empty'] }]
          )
        end

        it 'requires date to be valid' do
          data = build :activity_csv_data, date: 'zzz'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ['Date must be a valid datetime'] }]
          )
        end

        it 'requires creator column to be present' do
          data = build :activity_csv_data
          data[:creator] = nil
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ['Creator is empty'] }]
          )
        end

        it 'requires creator user to exist' do
          data = build :activity_csv_data, creator: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["User #{data[:creator]} could not be found"] }]
          )
        end

        it 'requires advertiser to exist' do
          data = build :activity_csv_data, advertiser: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Advertiser #{data[:advertiser]} could not be found"] }]
          )
        end

        it 'requires advertiser to match no more than 1 account' do
          data = build :activity_csv_data, advertiser: duplicate_advertiser2.name
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Advertiser #{data[:advertiser]} matched more than one account record"] }]
          )
        end

        it 'requires agency to exist' do
          data = build :activity_csv_data, agency: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Agency #{data[:agency]} could not be found"] }]
          )
        end

        it 'requires agency to match no more than 1 record' do
          data = build :activity_csv_data, agency: duplicate_agency2.name
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Agency #{data[:agency]} matched more than one account record"] }]
          )
        end

        it 'requires deal to exist' do
          data = build :activity_csv_data, deal: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Deal #{data[:deal]} could not be found"] }]
          )
        end

        it 'requires deal to match no more than 1 record' do
          data = build :activity_csv_data, deal: duplicate_deal2.name
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Deal #{data[:deal]} matched more than one deal record"] }]
          )
        end

        it 'requires meeting type to be present' do
          data = build :activity_csv_data
          data[:type] = nil
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ['Activity type is empty'] }]
          )
        end

        it 'requires activity type to exist' do
          data = build :activity_csv_data, type: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Activity type #{data[:type]} could not be found"] }]
          )
        end

        it 'requires contact to exist' do
          data = build :activity_csv_data, contacts: 'N/A'
          Activity.import(generate_csv(data), user.id, 'activities.csv')

          expect(import_log.rows_failed).to be 1
          expect(import_log.error_messages).to eq(
            [{ "row" => 1, "message" => ["Activity contact #{data[:contacts]} could not be found in the contacts list"] }]
          )
        end
      end
    end
  end
end
