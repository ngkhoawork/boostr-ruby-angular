class Api::InfluencerContentFeesController < ApplicationController
  respond_to :json

  def index
    results = influencer_content_fees.by_name(params[:name])
    response.headers['X-Total-Count'] = results.count.to_s
    render json: results.limit(limit).offset(offset)
    .as_json({include: {
        influencer: {},
        currency: {},
        content_fee: {}
      },
      methods: [:network_name]
    })
  end

  def create
    new_influencer_content_fee = influencer_content_fees.new(influencer_content_fee_params)
    
    if new_influencer_content_fee.save
      render json: new_influencer_content_fee.as_json({include: {
          influencer: {},
          currency: {},
          content_fee: {}
        }
      }), status: :created
    else
      render json: { errors: influencer_content_fee.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: influencer_content_fee.as_json({include: {
        influencer: {},
        currency: {},
        content_fee: {}
      }
    })
  end

  def update
    if influencer_content_fee.update_attributes(influencer_content_fee_params)
      render json: influencer_content_fee.as_json({include: {
          influencer: {},
          currency: {},
          content_fee: {}
        }
      }), status: :accepted
    else
      render json: { errors: influencer_content_fee.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_budget
    if content_fee.present?
      content_fee_product_budget_rows = content_fee.content_fee_product_budgets.for_year_month(influencer_content_fee.effect_date)
      if content_fee_product_budget_rows.count > 0
        content_fee_product_budget = content_fee_product_budget_rows.first
        content_fee_product_budget.budget_loc = influencer_content_fee.net_loc
        content_fee_product_budget.budget = influencer_content_fee.net
        if content_fee_product_budget.save
          content_fee.update_budget
          content_fee.io.update_total_budget
        end
      end
    end
    render nothing: true
  end

  def destroy
    influencer_content_fee.destroy

    render nothing: true
  end

  private

  def influencer_content_fee
    @influencer_content_fee ||= io.influencer_content_fees.find(params[:id])
  end

  def influencer_content_fee_params
    params.require(:influencer_content_fee).permit(
      :influencer_id,
      :content_fee_id,
      :effect_date,
      :fee_type,
      :fee_amount,
      :curr_cd,
      :gross_amount,
      :gross_amount_loc,
      :net,
      :net_loc,
      :asset
    )
  end

  def influencer_content_fees
    @influencer_content_fees ||= io.influencer_content_fees
  end

  def company
    @company ||= current_user.company
  end

  def content_fee
    @content_fee ||= influencer_content_fee.content_fee
  end

  def io
    @io ||= company.ios.find_by(id: params[:io_id])
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end
