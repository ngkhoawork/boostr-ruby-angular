require 'rails_helper'

RSpec.describe Api::BpsController, type: :controller do
  before do
    sign_in user
  end

  describe 'DELETE #destroy' do
    it 'should destroy bp' do
      create_bp_estimates

      delete :destroy, id: bp.id, format: :json

      expect(response).to be_success
      expect(Bp.all).to be_empty
      expect(BpEstimate.all).to be_empty
    end
  end

  private

  def bp
    @_bp ||= create :bp, time_period: time_period, company: company
  end

  def create_bp_estimates
    @bp_estimate ||= create :bp_estimate, bp: bp
  end

  def time_period
    @_time_period ||= create :time_period
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
