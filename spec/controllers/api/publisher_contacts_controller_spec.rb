require 'rails_helper'

describe Api::PublisherContactsController, type: :controller do
  before { sign_in user }

  describe 'PUT #add' do
    it 'add contact to publisher' do
      contact = create :contact, company: company

      expect(contact.publisher_id).to be_nil

      put :add, id: contact.id, publisher_id: publisher.id

      expect(contact.reload.publisher_id).to eq publisher.id
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
  
  def publisher
    @_publisher ||= create :publisher, company: company
  end
end
