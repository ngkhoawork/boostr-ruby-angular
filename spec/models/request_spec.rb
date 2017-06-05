require 'rails_helper'

RSpec.describe Request, type: :model do
  context 'validations' do
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_length_of(:resolution).is_at_most(1000) }
    it { should validate_presence_of(:resolution).on(:update) }
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
      allow(RequestsMailer).to receive(:new_request).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')
      recipients

      subject.update(
        status: 'New',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).to have_received(:new_request).with(recipients, subject.id)
      expect(message_delivery).to have_received(:deliver_later).with(queue: 'default')
    end

    it 'does not send email if status is not New' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(RequestsMailer).to receive(:new_request).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')
      recipients

      subject.update(
        status: 'Denied',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).not_to have_received(:new_request)
      expect(message_delivery).not_to have_received(:deliver_later)
    end
  end

  context 'after_update' do
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      request
      allow(RequestsMailer).to receive(:update_request).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(queue: 'default')
    end

    it 'sends email upon request completion' do
      request.update(
        status: 'Completed',
        description: 'Testing',
        request_type: 'Revenue',
        resolution: 'Totally Happening',
        company: company
      )

      expect(RequestsMailer).to have_received(:update_request).with(requester_email, request.id)
      expect(message_delivery).to have_received(:deliver_later).with(queue: 'default')
    end

    it 'sends email upon request rejection' do
      request.update(
        status: 'Denied',
        description: 'Testing',
        request_type: 'Revenue',
        resolution: 'Not Happening',
        company: company
      )

      expect(RequestsMailer).to have_received(:update_request).with(requester_email, request.id)
      expect(message_delivery).to have_received(:deliver_later).with(queue: 'default')
    end

    it 'does not send email if status is New' do
      request.update(
        status: 'New',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).not_to have_received(:update_request)
      expect(message_delivery).not_to have_received(:deliver_later)
    end
  end

  def recipients
    @_recipients ||= (create_list :user, 2, revenue_requests_access: true).map(&:email)
  end

  def company
    @_company ||= Company.first
  end

  def request
    @_request ||= create :request
  end

  def requester_email
    [request.requester.email]
  end
end
