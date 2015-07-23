require 'rails_helper'

RSpec.describe Contact, type: :model do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client) { create :client, company: company }

  context 'scopes' do
    context 'for_client' do
      let!(:contact) { create :contact, company: company, client: client }
      let!(:another_contact) { create :contact, company: company }

      it 'returns all when client_id is nil' do
        expect(Contact.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Contact.for_client(client.id).count).to eq(1)
      end
    end
  end

end