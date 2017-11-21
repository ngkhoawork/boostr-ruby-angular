require 'rails_helper'

RSpec.describe Api::PublishersController, type: :controller do
  let!(:publisher) do
    create(
      :publisher,
      name: 'Amazon',
      company: company,
      client: client,
      publisher_stage: publisher_stage,
      type: publisher_type_option
    )
  end
  before { sign_in user }

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
      let(:params) { { publisher_stage_id: publisher_stage.id } }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'when an appropriate stage filter is not included' do
      let(:params) { { publisher_stage_id: -1 } }

      it { subject; expect(first_item).to eq nil }
    end

    context 'when an appropriate type filter is included' do
      let(:params) { { type_id: publisher.type_id } }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'when an appropriate type filter is not included' do
      let(:params) { { type_id: -1 } }

      it { subject; expect(first_item).to eq nil }
    end

    context 'when an appropriate comscore filter is included' do
      let(:params) { { comscore: publisher.comscore } }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'when an appropriate comscore filter is not included' do
      let(:params) { { comscore: !publisher.comscore } }

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

  describe '#create' do
    let(:attributes) do
      attributes_for(:publisher).merge(
        client_id: client.id,
        publisher_stage_id: publisher_stage.id,
        type_id: publisher_type_option.id
      )
    end

    let(:params) { { publisher: attributes } }
    subject { post :create, params }

    it 'creates a publisher' do
      expect{subject}.to change{Publisher.count}.by(1)
      expect(response).to be_success
      expect(response_body[:id]).to eq Publisher.last.id
    end

    context 'when client_id is missed' do
      let(:attributes) { super().merge(client_id: nil) }

      it 'does not create a publisher' do
        expect{subject}.not_to change{Publisher.count}
        expect(response).to have_http_status(422)
        expect(response_body).to have_key :errors
      end
    end
  end

  describe '#update' do
    let(:params) { { id: publisher.id, publisher: { name: 'New publisher name' } } }
    subject { put :update, params }

    it 'updates a publisher' do
      expect{subject}.to change{publisher.reload.name}.to(params[:publisher][:name])
      expect(response).to be_success
      expect(response_body[:id]).to eq Publisher.last.id
    end

    context 'when name is invalid' do
      let(:params) { { id: publisher.id, publisher: { name: nil } } }

      it 'does not create a publisher' do
        expect{subject}.not_to change{publisher.reload.name}
        expect(response).to have_http_status(422)
        expect(response_body).to have_key :errors
      end
    end
  end

  describe '#settings' do
    let(:response_stage_ids) { response_body[:publisher_stages].map { |stage| stage[:id] } }
    let(:response_type_ids) { response_body[:publisher_types].map { |stage| stage[:id] } }

    subject { get :settings }

    before do
      publisher_type_option
      publisher_stage
    end

    it 'updates a publisher' do
      subject

      expect(response).to be_success
      expect(response_body[:publisher_types]).to be_a_kind_of Array
      expect(response_body[:publisher_stages]).to be_a_kind_of Array
      expect(response_type_ids).to include publisher_type_option.id
      expect(response_stage_ids).to include publisher_stage.id
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

  def type_field
    @_type_field ||= company.fields.where(subject_type: 'Publisher', name: 'Publisher Type').last
  end

  def client
    @_client ||= create(:client, :advertiser, company: company)
  end

  def publisher_stage
    @_publisher_stage ||= create(:publisher_stage, company: company, sales_stage: sales_stage)
  end

  def sales_stage
    @_sales_stage ||= create(:sales_stage, company: company)
  end

  def publisher_type_option
    @_publisher_type_option ||= create(:option, company: company, name: 'PUBLISHER TYPE 1', field: type_field)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def another_user
    @_another_user ||= create(:user, company: company)
  end
end
