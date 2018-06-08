require 'rails_helper'

describe Csv::ContactDecorator do
  let!(:company) { create :company }
  subject { described_class.new(contact) }

  let(:contact) { create :contact }

  it 'decorate activity successfully and return expected values' do
    expect(subject.id).to eq contact.id
    expect(subject.name).to eq contact.name
    expect(subject.position).to eq contact.position
    expect(subject.job_level).to eq contact.job_level
    expect(subject.works_at).to eq contact&.primary_client&.name
    expect(subject.email).to eq contact&.address&.email
    expect(subject.street1).to eq contact&.address&.street1
    expect(subject.street2).to eq contact&.address&.street2
    expect(subject.city).to eq contact&.address&.city
    expect(subject.state).to eq contact&.address&.state
    expect(subject.zip).to eq contact&.address&.zip
    expect(subject.country).to eq contact&.address&.country
    expect(subject.phone).to eq contact&.address&.phone
    expect(subject.mobile).to eq contact&.address&.mobile
    expect(subject.related_accounts).to eq contact.non_primary_clients.pluck(:name).join(';')
    expect(subject.created_date).to eq contact.created_at.strftime('%m/%d/%Y')
  end
end
