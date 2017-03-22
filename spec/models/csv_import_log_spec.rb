require 'rails_helper'

RSpec.describe CsvImportLog, type: :model do
  it 'counts rows' do
    subject.count_processed
    expect(subject.rows_processed).to be 1
  end

  it 'counts imported rows' do
    subject.count_imported
    expect(subject.rows_imported).to be 1
  end

  it 'counts failed rows' do
    subject.count_failed
    expect(subject.rows_failed).to be 1
  end

  it 'counts skipped rows' do
    subject.count_skipped
    expect(subject.rows_skipped).to be 1
  end

  it 'adds errors to log' do
    subject.count_processed
    subject.log_error('Undefined context')
    subject.count_processed
    subject.log_error('Undefined template')
    expect(subject.error_messages).to eq [{ row: 1, message: 'Undefined context' }, { row: 2, message: 'Undefined template' }]
  end

  it 'gets file name from path' do
    subject.set_file_source('./tmp/datafeed/example_file.csv')
    expect(subject.file_source).to eql 'example_file.csv'
  end
end
