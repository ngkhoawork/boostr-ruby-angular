class Api::InfluencersController < ApplicationController
  respond_to :json

  def index
    results = influencers.by_name(params[:name])
    response.headers['X-Total-Count'] = results.count.to_s
    render json: results.limit(limit).offset(offset)
    .as_json({include: {
        agreement: {},
        values: {}
      },
      methods: [:network_name]
    })
  end

  def create
    influencer = influencers.new(influencer_params)

    if influencer.save
      render json: influencer.as_json({include: {
          agreement: {},
          values: {}
        }
      }), status: :created
    else
      render json: { errors: influencer.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: influencer.as_json({include: {
        agreement: {},
        values: {}
      }
    })
  end

  def update
    if influencer.update_attributes(influencer_params)
      render json: influencer.as_json({include: {
          agreement: {},
          values: {}
        }
      }), status: :accepted
    else
      render json: { errors: influencer.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    influencer.destroy

    render nothing: true
  end

  private

  def influencer
    @influencer ||= company.influencers.find(params[:id])
  end

  def influencer_params
    params.require(:influencer).permit(
      :company_id,
      :name,
      :active,
      :address,
      :email,
      :phone,
      {
        agreement_attributes: [
          :id,
          :fee_type,
          :amount
        ],
        values_attributes: [
          :id,
          :field_id,
          :option_id,
          :value
        ],
      }
    )
  end

  def influencers
    @influencers ||= company.influencers.order(:name)
  end

  def company
    @company ||= current_user.company
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end
