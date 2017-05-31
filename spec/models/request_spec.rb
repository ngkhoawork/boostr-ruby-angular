require 'rails_helper'

RSpec.describe Request, type: :model do
  context 'validations' do
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_length_of(:resolution).is_at_most(1000) }
  end

  context 'associations' do
    it { should belong_to(:requester) }
    it { should belong_to(:assignee) }
    it { should belong_to(:deal) }
    it { should belong_to(:requestable) }
    it { should belong_to(:company) }
  end

  context 'after_create' do
    it 'triggers email notification upon new revenue request' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(RequestsMailer).to receive(:send_email).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')
      recipients

      subject.update(
        status: 'New',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).to have_received(:send_email).with(recipients, subject.id)
      expect(message_delivery).to have_received(:deliver_later).with(queue: 'default')
    end

    it 'does not send email if status is not New' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(RequestsMailer).to receive(:send_email).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')
      recipients

      subject.update(
        status: 'Closed',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).not_to have_received(:send_email)
      expect(message_delivery).not_to have_received(:deliver_later)
    end
  end

  def recipients
    @_recipients ||= (create_list :user, 2, revenue_requests_access: true).map(&:email)
  end

  def company
    @_company ||= Company.first
  end
end
