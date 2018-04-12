class Api::V2::AccountCfNamesController < ApiController
  respond_to :json

  def index
    render json: account_cf_names.order(:position).as_json(
      includes: {
        account_cf_options: {
          only: [:id, :value]
        }
      }
    )
  end

  private

  def account_cf_names
    @account_cf_names ||= current_user.company.account_cf_names
  end
end
