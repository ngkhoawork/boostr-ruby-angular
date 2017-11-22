require 'rails_helper'

RSpec.describe Api::PublishersController, type: :controller do
  before { sign_in user }

  let!(:publisher_stage) { PublisherStage.create(publishers: [publisher], company: company, sales_stage: stage) }

  describe '#index' do
    let(:params) { {} }
    subject { get :index, params }

    it 'returns a list of publishers' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:id]).to eq publisher.id
    end

    context 'when an appropriate stage filter is included' do
      let(:address) { publisher.address }
      let(:params) { { stage_id: publisher_stage.id } }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'when an appropriate stage filter is not included' do
      let(:params) { { stage_id: -1 } }

      it { subject; expect(first_item).to eq nil }
    end

    context 'when my_publishers_bool filter is included' do
      let(:params) { { my_publishers_bool: true } }

      context 'and current user has publisher connections' do
        before { publisher.users << user }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end

      context 'and current user does not have publisher connections' do
        before { publisher.users << another_user }

        it { subject; expect(first_item).to be_nil }
      end
    end

    context 'when a search term is included' do
      let(:params) { { q: q } }

      context 'and a term is an exact match' do
        let(:q) { 'Amazon' }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end

      context 'and a term is multi-word' do
        let(:q) { 'The Amazon corp.' }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end

      context 'and a term is misspelled' do
        let(:q) { 'Amizon' }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end

      context 'and a term is misspelled and multi-word' do
        let(:q) { 'The Amizon corp.' }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end
    end
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def first_item
    @_first_item ||= response_body.first
  end

  def company
    @_company ||= create(:company)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def another_user
    @_another_user ||= create(:user, company: company)
  end

  def publisher
    @_publisher ||= create(:publisher, name: 'Amazon', company: company)
  end

  def stage
    @_stage ||= create(:sales_stage, company: company)
  end
end
