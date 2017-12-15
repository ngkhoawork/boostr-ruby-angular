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

    context 'when custom fields params are included' do
      let(:params) do
        {
          custom_field_names: [
            {
              id: publisher_custom_field_name.id,
              field_option: custom_field_value
            }
          ]
        }
      end

      before do
        publisher.create_publisher_custom_field(company: company, text1: publisher_custom_field_option.value)
      end

      context 'and a field value param fits a publisher' do
        let(:custom_field_value) { publisher_custom_field_option.value }

        it { subject; expect(first_item[:id]).to eq publisher.id }
      end

      context 'and a field value param does not fit a publisher' do
        let(:custom_field_value) { FFaker::Lorem.phrase }

        it { subject; expect(first_item).to eq nil }
      end
    end
  end

  describe '#pipeline' do
    let(:params) { {} }
    let(:response_publisher_ids) { first_item[:publishers].map { |p| p[:id] } }

    subject { get :pipeline, params }

    it 'returns publishers by stages' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:id]).to eq publisher_stage.id
      expect(response_publisher_ids).to include publisher.id
    end

    context 'when an appropriate filter is included' do
      let(:params) { { comscore: publisher.comscore } }

      it { subject; expect(first_item[:publishers].map { |p| p[:id] }).to include publisher.id }
    end

    context 'when an appropriate filter is not included' do
      let(:params) { { comscore: !publisher.comscore } }

      it { subject; expect(first_item[:publishers].map { |p| p[:id] }).not_to include publisher.id }
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
      expect{subject}.to change{Publisher.count}.by(1).and \
                         change{PublisherMember.count}.by(1)
      expect(response).to have_http_status(201)
      expect(response_body[:id]).to eq Publisher.last.id
    end
  end

  describe '#update' do
    let(:params) { { id: publisher.id, publisher: { name: 'New publisher name' } } }
    subject { put :update, params }

    it 'updates a publisher' do
      expect{subject}.to change{publisher.reload.name}.to(params[:publisher][:name])
      expect(response).to have_http_status(200)
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

    context 'when publisher_members_attributes are provided' do
      let(:response_user_ids) { response_body[:publisher_members].map { |u| u[:user_id] } }
      let!(:user_membership) { publisher.publisher_members.create(user: user) }

      context 'for adding a new member' do
        let(:params) do
          {
            id: publisher.id,
            publisher: {
              publisher_members_attributes: [
                {
                  user_id: another_user.id
                }
              ]
            }
          }
        end

        it 'creates a publisher member' do
          expect{subject}.to change{publisher.publisher_members.count}.by(1)
          expect(response).to have_http_status(200)
          expect(response_user_ids).to include another_user.id
          expect(response_user_ids).to include user.id
        end
      end

      context 'for deleting an existing member' do
        let(:params) do
          {
            id: publisher.id,
            publisher: {
              publisher_members_attributes: [
                {
                  id: user_membership.id,
                  _destroy: true
                }
              ]
            }
          }
        end

        it 'deletes a publisher member' do
          subject
          expect(response).to have_http_status(200)
          expect(response_user_ids).not_to include user.id
        end
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

  describe '#pipeline_headers' do
    let(:response_stage_ids) { response_body.map { |stage| stage[:id] } }

    subject { get :pipeline_headers }

    before { publisher_stage }

    it 'returns pipeline headers' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(response_stage_ids).to include publisher_stage.id
      expect(first_item).to have_key :id
      expect(first_item).to have_key :name
      expect(first_item).to have_key :probability
      expect(first_item).to have_key :estimated_monthly_impressions_sum
      expect(first_item).to have_key :actual_monthly_impressions_sum
      expect(first_item).to have_key :publishers_count
    end
  end

  describe '#all_fields_report' do
    let(:params) { { format: :json } }

    subject { get :all_fields_report, params }

    before do
      publisher.create_publisher_custom_field(company: company, text1: publisher_custom_field_option.value)
    end

    it 'has an appropriate structure' do
      subject
      expect(response).to be_success
      expect(response_body).to be_kind_of Array
      expect(first_item).to have_key :name
      expect(first_item).to have_key :comscore
      expect(first_item).to have_key :website
      expect(first_item).to have_key :estimated_monthly_impressions
      expect(first_item).to have_key :actual_monthly_impressions
      expect(first_item).to have_key :publisher_custom_field
      expect(first_item[:publisher_custom_field][0][:field_label]).to eq publisher_custom_field_name.field_label
      expect(first_item[:publisher_custom_field][0][:field_type]).to eq publisher_custom_field_name.field_type
      expect(first_item[:publisher_custom_field][0][:field_value]).to eq publisher_custom_field_option.value
    end
    it { subject; expect(first_item[:id]).to eq publisher.id }

    context 'and when params include appropriate "publisher_stage_id"' do
      let(:params) { super().merge(publisher_stage_id: publisher.publisher_stage_id) }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'and when params does not include appropriate "publisher_stage_id"' do
      let(:params) { super().merge(publisher_stage_id: -1) }

      it { subject; expect(response_body).to be_empty }
    end

    context 'and when params include appropriate "team_id"' do
      let(:params) { super().merge(team_id: team.id) }

      before { publisher.users << user }

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'and when params does not include appropriate "team_id"' do
      let(:params) { super().merge(team_id: -1) }

      it { subject; expect(response_body).to be_empty }
    end

    context 'and when params include appropriate "created_at"' do
      let(:params) do
        super().merge(
          created_at_start: publisher.created_at - 1.minute,
          created_at_end: publisher.created_at + 1.minute
        )
      end

      it { subject; expect(first_item[:id]).to eq publisher.id }
    end

    context 'and when params does not include appropriate "created_at"' do
      let(:params) do
        super().merge(
          created_at_start: publisher.created_at - 2.minute,
          created_at_end: publisher.created_at - 1.minute
        )
      end

      it { subject; expect(response_body).to be_empty }
    end
  end

  describe '#destroy' do
    it 'delete publisher' do
      expect{
        delete :destroy, id: publisher.id
      }.to change{Publisher.count}.by(-1)
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
    @_user ||= create(:user, company: company, team: team)
  end

  def another_user
    @_another_user ||= create(:user, company: company)
  end

  def team
    @_team ||= create(:team, company: company)
  end

  def publisher_custom_field_name
    @_publisher_custom_field_name ||=
      create(
        :publisher_custom_field_name,
        company: company,
        field_label: 'Last release date',
        field_type: 'text',
        field_index: 1,
        position: 1
      )
  end

  def publisher_custom_field_option
    @_publisher_custom_field_option ||=
      create(:publisher_custom_field_option, publisher_custom_field_name: publisher_custom_field_name)
  end
end
