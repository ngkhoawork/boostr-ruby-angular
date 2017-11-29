require 'rails_helper'

describe Importers::UsersService do

  subject { Importers::UsersService.new(inviter: inviter, company_id: inviter.company_id, file: file, import_subject: 'User', import_source: 'ui') }

  describe '#perform' do
    let(:inviter) { create(:user) }

    before do
      allow(File).to receive(:open).with(file, 'r:ISO-8859-1').and_return(file)
    end

    context 'creates new users from csv file' do
      before do
        allow(File).to receive(:open).with(file, 'r:ISO-8859-1').and_return(file)
        allow(subject).to receive(:parsed_csv).and_return([correct_row])
      end

      it { expect { subject.perform }.to change{ User.count }.by(+1) }

      it 'creates user with correct attributes' do
        subject.perform

        created_user = User.last

        expect(created_user.is_admin).to eq(user_data_row[:is_admin])
        expect(created_user.email).to eq(user_data_row[:email])
        expect(created_user.name).to eq(user_data_row[:name])
        expect(created_user.title).to eq(user_data_row[:title])
        expect(created_user.default_currency).to eq(user_data_row[:currency])
        expect(created_user.user_type).to eq(ACCOUNT_MANAGER)
        expect(created_user.revenue_requests_access).to eq(user_data_row[:revenue_requests])
        expect(created_user.employee_id).to eq(user_data_row[:employee_id])
        expect(created_user.office).to eq(user_data_row[:office])
        expect(created_user.is_active).to eq(true)
      end
    end
    context 'logging the results' do
      context 'for valid rows' do
        before do
          allow(subject).to receive(:parsed_csv).and_return([correct_row])
        end

        it 'saves parse information to the log' do
          subject.perform

          import_log = CsvImportLog.last
          expect(import_log.rows_processed).to eq 1
          expect(import_log.rows_imported).to eq 1
          expect(import_log.rows_failed).to eq 0
          expect(import_log.rows_skipped).to eq 0
          expect(import_log.file_source).to eq 'user_file.csv'
          expect(import_log.object_name).to eq 'User'
        end
      end

      context 'for invalid rows' do
        before do
          allow(subject).to receive(:parsed_csv).and_return([incorrect_row])
        end

        it 'saves parse information to the log' do
          subject.perform

          import_log = CsvImportLog.last
          expect(import_log.rows_processed).to eq 1
          expect(import_log.rows_imported).to eq 0
          expect(import_log.rows_failed).to eq 1
          expect(import_log.rows_skipped).to eq 0
          expect(import_log.file_source).to eq 'user_file.csv'
          expect(import_log.object_name).to eq 'User'
        end
      end

      it 'catches internal server errors' do
        allow(subject).to receive(:parsed_csv).and_return([correct_row])

        user_data = double('user')

        allow(Csv::User).to receive(:new).and_return(user_data)
        expect(user_data).to receive(:valid?).and_return(:true)
        expect(user_data).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

        subject.perform
        import_log = CsvImportLog.last
        error = import_log.error_messages.first

        expect(error['row']).to eq(1)
        expect(error['message']).to include('Internal Server Error')
      end
    end


  end

  private

  def correct_row
    @_correct_row ||= user_data_row
  end

  def incorrect_row
    @_incorrect_row ||= user_data_row(email: nil, name: nil, user_type: nil, status: nil)
  end

  def user_data_row(options = {})
    @_user_data ||= build(:user_csv_data, options)
  end

  def file
    './tmp/user_file.csv'
  end

end