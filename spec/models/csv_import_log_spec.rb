require 'rails_helper'

RSpec.describe CsvImportLog, type: :model do
  it { should belong_to(:company) }

  context 'after_create' do
    let!(:notification) {
      create :notification,
      company: company,
      recipients: 'xyz@example.net,
      zyzz@kimdotnet.us',
      active: true,
      name: "Error Log"
    }

    it 'triggers email notification if there were errors' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(CsvImportLogNotificationMailer).to receive(:send_email).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')

      subject.update(
        company: company,
        rows_failed: 1,
        error_messages: [{row: 1, message: 'Undefined Context'}]
      )

      expect(CsvImportLogNotificationMailer).to have_received(:send_email).with(recipients, subject.id)
      expect(message_delivery).to have_received(:deliver_later).with(queue: 'default')
    end

    it 'does not send email if there were NO errors' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(CsvImportLogNotificationMailer).to receive(:send_email).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')

      subject.update(
        company: company,
      )

      expect(CsvImportLogNotificationMailer).not_to have_received(:send_email).with(recipients, subject.id)
      expect(message_delivery).not_to have_received(:deliver_later).with(queue: 'default')
    end
  end

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

  def company
    @_company ||= create :company
  end

  def recipients
    notification.recipients_arr
  end
end
