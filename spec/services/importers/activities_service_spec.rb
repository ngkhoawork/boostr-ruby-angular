require 'rails_helper'

describe Importers::ActivitiesService do
  describe '#perform' do
    before(:each) do
      @file = File.open(file_path, 'w') do |f|
        f.puts(
          "Activity Id,\
           Date,\
           Creator,\
           Advertiser,\
           Agency,\
           Deal,\
           Type,\
           Comments,\
           Contacts,\
           #{custom_field_name_1.to_csv_header}"
        )
        f.puts(
          "#{csv_activity_id},\
           #{csv_date},\
           #{csv_creator},\
           #{csv_advertiser},\
           #{csv_agency},\
           #{csv_deal},\
           #{csv_type},\
           #{csv_comments},\
           #{csv_contacts},\
           #{csv_custom_field_value_1}"
        )
      end
    end
    after(:each) { FileUtils.rm(file_path) if File.exist?(file_path) }

    subject { described_class.new(params).perform }

    it do
      expect{subject}.to change{Activity.count}.by(1).and change{CsvImportLog.count}.by(1)

      expect(last_created_activity.company_id).to eq company.id
      expect(last_created_activity.happened_at.strftime('%m/%d/%Y')).to eq csv_date
      expect(last_created_activity.user.email).to eq csv_creator
      expect(last_created_activity.client.name).to eq csv_advertiser
      expect(last_created_activity.agency.name).to eq csv_agency
      expect(last_created_activity.deal.name).to eq csv_deal
      expect(last_created_activity.activity_type.name).to eq csv_type
      expect(last_created_activity.comment).to eq csv_comments
      expect(last_created_activity.contacts.map(&:email).join(';')).to eq csv_contacts
      expect(last_created_activity.custom_field.string1).to eq csv_custom_field_value_1

      expect(last_created_log.rows_processed).to eq 1
      expect(last_created_log.rows_imported).to eq 1
      expect(last_created_log.rows_failed).to eq 0
    end

    context 'date format is invalid' do
      let(:csv_date) { '31231.34.32' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must have valid date\/datetime format/i
      end
    end

    context 'creator can not match' do
      let(:csv_creator) { 'non-match' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match users/i
      end
    end

    context 'advertiser can not match' do
      let(:csv_advertiser) { 'non-match' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match clients/i
      end
    end

    context 'agency can not match' do
      let(:csv_agency) { 'non-match' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match clients/i
      end
    end

    context 'deal can not match' do
      let(:csv_deal) { 'non-match' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match deals/i
      end
    end

    context 'type can not match' do
      let(:csv_type) { 'non-match' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match activity types/i
      end
    end

    context 'contacts can not match' do
      let(:csv_contacts) { 'non-match1; non-match2' }

      it do
        expect{subject}.not_to change{Activity.count}
        expect(last_created_log.rows_failed).to eq 1
        expect(last_created_log.error_messages[0]['message'].first).to match /must match contacts/i
      end
    end
  end

  private

  def params
    {
      file: file_path,
      import_subject: 'Activity',
      user_id: user.id,
      company_id: company.id,
      original_filename: 'activities.csv'
    }
  end

  def company
    @_company ||= create(:company)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def advertiser
    @_advertiser ||= create(:client, :advertiser, company: company, name: "Advertiser_#{Time.now.to_i}")
  end
  def agency
    @_agency ||= create(:client, :agency, company: company, name: "Agency_#{Time.now.to_i}")
  end

  def deal
    @_deal ||= create(:deal, company: company, creator: user, name: "Deal_#{Time.now.to_i}")
  end

  def activity_type
    company.activity_types.find_or_create_by!(name:'Initial Meeting', action:'had initial meeting with', position: 1)
  end

  def contacts
    @_contacts ||= create_list(:contact, 2, company: company)
  end

  def custom_field_name_1
    @_custom_field_name_1 =
      create(
        :custom_field_name,
        subject_type: 'Activity',
        field_type: 'text',
        field_label: 'Activity CF 1',
        position: 1,
        company: company
      )
  end

  def last_created_activity
    @_last_created_activity ||= Activity.last
  end

  def last_created_log
    @_last_created_log ||= CsvImportLog.last
  end

  def csv_activity_id
    nil
  end

  def csv_date
    @_csv_date ||= DateTime.current.strftime('%m/%d/%Y')
  end

  def csv_creator
    user.email
  end

  def csv_advertiser
    advertiser.name
  end

  def csv_agency
    agency.name
  end

  def csv_deal
    deal.name
  end

  def csv_type
    activity_type.name
  end

  def csv_comments
    @_csv_comments ||= FFaker::BaconIpsum.paragraph
  end

  def csv_contacts
    contacts.map(&:email).join(';')
  end

  def csv_custom_field_value_1
    @_csv_custom_field_value_1 ||= FFaker::Lorem.word
  end

  def file_path
    @_file_path ||= File.join(ensure_tmp_folder, 'PublisherDailyActualsImport.csv')
  end

  def ensure_tmp_folder
    FileUtils.mkdir_p('tmp') unless File.directory?('tmp')
    'tmp'
  end
end
