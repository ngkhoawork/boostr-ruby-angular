class Api::InfluencerContentFeesController < ApplicationController
  require 'timeout'
  respond_to :json

  def index
    results = influencer_content_fees
      .for_influencer_id(params[:influencer_id])
      .by_effect_date(asset_date_start, asset_date_end)
    respond_to do |format|
      format.json {
        response.headers['X-Total-Count'] = results.count.to_s
        render json: results
        .as_json({include: {
            influencer: {
              methods: [:network_name]
            },
            currency: {},
            content_fee: {
              include: {
                io: {
                  include: {
                    agency: {},
                    advertiser: {}
                  },
                  methods: [:account_manager, :seller],
                  only: [:id, :name, :deal_id, :io_number, :start_date]
                },
                product: {}
              }
            }
          },
          methods: [:team_name]
        })
      }
      format.csv {
        begin
          Timeout::timeout(240) {
            send_data InfluencerContentFee.to_csv(results), filename: "influencer-budget-detail-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
    
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

  def import
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Csv::InfluencerContentFee',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: 'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)'
      }, status: :ok
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
    @influencer_content_fee ||= company.influencer_content_fees.find(params[:id])
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
    return @influencer_content_fees ||= io.influencer_content_fees if io.present?
    return @influencer_content_fees ||= company.influencer_content_fees
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

  def asset_date_start
    @asset_date_start ||= params[:asset_date_start]
  end

  def asset_date_end
    @asset_date_end ||= params[:asset_date_end]
  end
end
