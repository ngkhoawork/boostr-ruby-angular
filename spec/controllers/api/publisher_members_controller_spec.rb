require 'rails_helper'

describe Api::PublisherMembersController do
  before { sign_in user }

  describe 'POST #create' do
    it 'creates publisher member successfully' do
      expect {
        post :create, id: publisher.id
      }.to change(Publisher, :count).by(1)
    end
  end

  describe 'PUT #update' do
    it 'update owner successfully' do
      publisher_member = create :publisher_member, user: user, publisher: publisher, owner: false

      put :update, id: publisher_member.id, owner: true

      expect(publisher_member.reload.owner).to be_truthy
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def publisher
    @_publisher ||= create :publisher, company: company
  end

  def user
    @_user ||= create :user, company: company
  end
end
