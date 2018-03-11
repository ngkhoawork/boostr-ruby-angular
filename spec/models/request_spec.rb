require 'rails_helper'

describe Request do
  let!(:company) { create :company, :fast_create_company }

  context 'validations' do
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_length_of(:resolution).is_at_most(1000) }

    context 'request denied' do
      before { allow(subject).to receive(:request_is_denied).and_return(true) }
      it { should validate_presence_of(:resolution).on(:update) }
    end
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
      allow(message_delivery).to receive(:deliver_later).with(wait: 5.seconds, queue: 'default')
      recipient_email

      subject.update(
        status: 'New',
        description: 'Testing',
        request_type: 'Revenue',
        company: company
      )

      expect(RequestsMailer).to have_received(:new_request).with(recipient_email, subject.id)
      expect(message_delivery).to have_received(:deliver_later).with(wait: 5.seconds, queue: 'default')
    end

    it 'does not send email if status is not New' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      allow(RequestsMailer).to receive(:new_request).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(wait: 5.seconds, queue: 'default')
      recipient_email

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
      request(status: 'New')
      allow(RequestsMailer).to receive(:update_request).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).with(wait: 5.seconds, queue: 'default')
      recipient_email
    end

    it 'sends email upon request rejection' do
      request.update(
        status: 'Denied',
        description: 'Testing',
        request_type: 'Revenue',
        resolution: 'Not Happening',
        company: company
      )

      expect(RequestsMailer).to have_received(:update_request).with(requester_email + assignee_email, request.id)
      expect(message_delivery).to have_received(:deliver_later).with(wait: 5.seconds, queue: 'default')
    end

    it 'sends email upon request completion' do
      request.update(
        status: 'Completed',
        description: 'Testing',
        request_type: 'Revenue',
        resolution: 'Let\s totally do it!',
        company: company
      )

      expect(RequestsMailer).to have_received(:update_request).with(requester_email + assignee_email, request.id)
      expect(message_delivery).to have_received(:deliver_later).with(wait: 5.seconds, queue: 'default')
    end

    it 'does not send update_request if status is New' do
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

  it 'sends email upon request completion' do
    RequestsMailer.update_request(requester_email, request.id).deliver_now
    requests_mailer = ActionMailer::Base.deliveries.last

    expect(requests_mailer.to).to eq requester_email
    expect(requests_mailer.subject).to eq "#{request.request_type} Request for Deal #{request.deal.name}"
  end

  it 'sends new_request if status is New' do
    RequestsMailer.new_request(requester_email, request.id).deliver_now
    requests_mailer = ActionMailer::Base.deliveries.last

    expect(requests_mailer.to).to eq requester_email
    expect(requests_mailer.subject).to eq "You Have a New #{request.request_type} Request"
  end

  def recipient_email
    @_recipient_email ||= [(create :user, revenue_requests_access: true).email]
  end

  # def company
  #   @_company ||= create :company, :fast_create_company
  # end

  def request(opts = {})
    @_request ||= create :request, opts
  end

  def requester_email
    [request.requester.email]
  end

  def assignee_email
    [request.assignee.email]
  end
end
