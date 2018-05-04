require 'rails_helper'

describe Api::SalesStagesController, type: :controller do
  before { sign_in user }

  describe 'GET #index' do
    it 'return only company related sales stages' do
      create_list :sales_stage, 5, company: company
      create_list :sales_stage, 5, company: create(:company)

      get :index, format: :json

      expect(json_response.length).to eq(5)
    end
  end

  describe 'POST #create' do
    it 'creates a new sales stage successfully' do
      expect do
        post :create, sales_stage: valid_sales_stage_params, format: :json
      end.to change(SalesStage, :count).by(1)
    end

    it 'failed when params are invalid' do
      expect do
        post :create, sales_stage: invalid_sales_stage_params, format: :json
      end.to_not change(SalesStage, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates sales stage successfully' do
      put :update, id: sales_stage.id, sales_stage: valid_sales_stage_params, format: :json

      sales_stage.reload

      expect(sales_stage.name).to eq valid_sales_stage_params[:name]
      expect(sales_stage.probability).to eq valid_sales_stage_params[:probability]
    end
    
    it 'failed when params are invalid' do
      put :update, id: sales_stage.id, sales_stage: invalid_sales_stage_params, format: :json

      expect(sales_stage.reload.name).not_to eq invalid_sales_stage_params[:name]
      expect(sales_stage.reload.probability).not_to eq invalid_sales_stage_params[:probability]
    end
  end

  describe 'PUT #update_positions' do
    it 'update sales stages positions successfully' do
      sales_stages = create_list :sales_stage, 2, company: company
      sales_stages_ids = sales_stages.map(&:id)
      position_params =  Hash[sales_stages_ids.map { |i| [i.to_s, i+1] }]

      put :update_positions, sales_stages_position: position_params, format: :json

      sales_stages.map(&:reload)

      expect(sales_stages.first.position).to eq(position_params[sales_stages.first.id.to_s])
      expect(sales_stages.last.position).to eq(position_params[sales_stages.last.id.to_s])
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def sales_stage
    @_sales_stage ||= create :sales_stage, company: company
  end

  def valid_sales_stage_params
    @_valid_sales_stage_params ||= {
      company_id: company.id,
      position: 1,
      name: 'Won',
      probability: 100
    }
  end

  def invalid_sales_stage_params
    {
      company_id: company.id,
      position: 1,
      name: '',
      probability: 10
    }
  end
end
