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

  describe 'POST #create' do
    it 'create contact successfully' do
      expect{
        post :create, contact: contact_params
      }.to change{Contact.count}.by(1)
    end

    it 'failed to create contact' do
      expect{
        post :create, contact: { name: 'Name' }
      }.not_to change{Contact.count}
    end
  end

  describe 'PUT #update' do
    it 'update contact successfully' do
      put :update, id: contact.id, contact: contact_params

      expect(contact.reload.name).to eq contact_params[:name]
    end

    it 'failed to update contact' do
      put :update, id: contact.id, contact: { name: '' }

      expect(contact.reload.name).not_to be_nil
    end
  end

  describe 'DELETE #destroy' do
    it 'remove contact from publisher successfully' do
      delete :destroy, id: contact.id

      expect(contact.reload.publisher_id).to be_nil
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

  def contact
    @_contact ||= create :contact, company: company, publisher: publisher
  end

  def contact_params
    @_contact_params ||= {
      name: 'Aisha Joy',
      position: 'Regional  Analyst',
      publisher_id: publisher.id,
      address_attributes: {
        email: 'test@email.com'
      }
    }
  end

  def address
    attributes_for(:address)
  end
end
