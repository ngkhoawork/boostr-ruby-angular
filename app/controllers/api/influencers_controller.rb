class Api::InfluencersController < ApplicationController
  respond_to :json

  def index
    results = influencers.by_name(params[:name])

    respond_to do |format|
      format.json {
        response.headers['X-Total-Count'] = results.count.to_s
        render json: results.limit(limit).offset(offset)
        .as_json({include: {
            agreement: {},
            values: {},
            address: {}
          },
          methods: [:network_name]
        })
      }

      format.csv {
        require 'timeout'
        begin
          send_data Csv::InfluencerService.new(results).perform,
                  filename: "influencers-#{Date.today}.csv"
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Influencer',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    else
      influencer = influencers.new(influencer_params)

      if influencer.save
        render json: influencer.as_json({include: {
            agreement: {},
            values: {},
            address: {}
          }
        }), status: :created
      else
        render json: { errors: influencer.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    render json: influencer.as_json({include: {
        agreement: {},
        values: {},
        address: {},
        influencer_content_fees: {
          include: {
            currency: {},
            content_fee: {
              include: {
                io: {},
                product: {}
              }
            }
          }
        }
      }
    })
  end

  def update
    if influencer.update_attributes(influencer_params)
      render json: influencer.as_json({include: {
          agreement: {},
          values: {},
          address: {}
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
        address_attributes: [
          :id,
          :country,
          :street1,
          :street2,
          :city,
          :state,
          :zip,
          :phone,
          :mobile,
          :email
        ],
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
