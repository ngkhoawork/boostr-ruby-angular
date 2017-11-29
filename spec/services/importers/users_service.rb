require 'rails_helper'

describe Importers::UsersService do

  subject { Importers::UsersService.new(inviter: inviter, company_id: inviter.company_id, file: file, import_subject: 'User', import_source: 'ui') }

  describe '#perform' do
    let(:inviter) { create(:user) }

    context 'creates new users from csv file' do
      before do
        allow(File).to receive(:open).with(file, 'r:ISO-8859-1').and_return(file)
        allow(subject).to receive(:parsed_csv).and_return([user_data_row])
      end

      it { expect { subject.perform }.to change{ User.count }.by(+1) }

      context 'logging the results' do
        it { expect { subject.perform }.to change(CsvImportLog, :count).by 1 }

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

        it 'catches internal server errors' do
          user_data = double('user')
          allow(UserCsv).to receive(:new).and_return(user_data)
          expect(user_data).to receive(:valid?).and_return(:true)
          expect(user_data).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

          subject.perform
          import_log = CsvImportLog.last
          error = import_log.error_messages.first

          expect(error["row"]).to eq(1)
          expect(error["message"]).to include('Internal Server Error')
        end
      end

    end

  end

  private

  def user_csv
    @_user_csv ||= generate_csv(user_data_row)
  end

  def user_data_row(options = {})
    @_user_data ||= build(:user_csv_data, options)
  end

  def file
    './tmp/user_file.csv'
  end

end