require 'rails_helper'

describe Api::Leads::IndexSerializer do
  let!(:client) { create :client, name: 'Apple', company: company }

  it 'includes the expected attributes' do
    expect(index_serializer.id).to eq lead.id
    expect(index_serializer.name).to eq lead.name
    expect(index_serializer.title).to eq lead.title
    expect(index_serializer.email).to eq lead.email
    expect(index_serializer.country).to eq lead.country
    expect(index_serializer.state).to eq lead.state
    expect(index_serializer.budget).to eq lead.budget
    expect(index_serializer.notes).to eq lead.notes
    expect(index_serializer.created_at).to eq lead.created_at
    expect(index_serializer.rejected_at).to eq lead.rejected_at
    expect(index_serializer.user).to eq user.serializable_hash(only: [:id], methods: [:name])
    expect(index_serializer.contact).to eq contact.serializable_hash(only: [:id, :name])
    expect(index_serializer.untouched_days).to eq '0'
  end

  private

  def index_serializer
    described_class.new(lead)
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def contact
    @_contact ||= create :contact, company: company
  end

  def lead
    @_lead ||= create :lead, company: company, contact: contact, user: user, status: Lead::NEW
  end
end
