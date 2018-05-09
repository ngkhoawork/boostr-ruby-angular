require 'rails_helper'

describe ProcessRawContactDataService do
  describe '#perform' do
    let(:valid_and_invalid_guests) { invalid_guests + valid_guest }

    it 'extract and create contacts for valid guests from the list' do
      result = described_class.new(valid_and_invalid_guests, user).perform

      expect(result.length).to eq 1
    end

    context 'with existing contacts' do
      let(:existing_contacts) { [] }
      let(:existing_contacts_with_valid_guest) { existing_contacts + valid_guest }

      before do
        contacts.each do |contact|
          existing_contacts << { name: contact.name, address: { email: contact.address.email } }
        end
      end

      it 'return existing company contacts' do
        result = described_class.new(existing_contacts, user).perform

        expect(result.length).to eq 5
      end

      it 'return existing company contacts and create new for contacts out of raw data' do
        result = described_class.new(existing_contacts_with_valid_guest, user).perform

        expect(result.length).to eq 6
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def team
    @_team ||= create :parent_team, company: company
  end

  def user
    create :user, team: team, company: company
  end

  def contacts
    create_list :contact, 5, company: company
  end

  def invalid_guests
    [1, 2]
  end

  def valid_guest
    [{ name: 'Peggy M. Castle', address: { email: 'PeggyMCastle@rhyta.com' } }]
  end
end
