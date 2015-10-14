require 'rails_helper'

RSpec.describe ClientType, type: :model do

  let(:company) { create :company }
  let(:client_type) { create :client_type, company: company }

  context 'validations' do
    context 'unique name' do
      it 'is valid even when another deleted client_type exists' do
        client_type.destroy
        new_client_type = build :client_type, company: company, name: client_type.name
        expect(new_client_type).to be_valid
      end
    end
  end
end
