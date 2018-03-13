class Api::IosController < ApplicationController
  respond_to :json

  def index
    render json: ios
  end

  def show
    render json: io, serializer: Ios::IoSerializer
  end

  def create
    io = company.ios.new(io_params)

    if io.deal_id
      io.io_number = io.deal_id
    elsif io.external_io_number
      io.io_number = io.external_io_number
    end

    if io.save
      render json: io, serializer: Ios::IoSerializer, status: :created
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if io.update_attributes(io_params)
      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def update_influencer_budget
    if io
      errors = []
      io.influencer_content_fees.each do |influencer_content_fee|
        if influencer_content_fee.effect_date < io.start_date || influencer_content_fee.effect_date > io.end_date
          errors << "Asset date of influencer #{influencer_content_fee.influencer.name} is out of IO's date range."
        end
      end
      if errors.count > 0
        render json: { errors: errors }, status: :unprocessable_entity
        return
      end
      io.update_influencer_budget
      io.reload
      render json: io, serializer: Ios::IoSerializer
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.is_admin
      io.destroy

      render nothing: true
    else
      render json: { errors: 'You can\'t delete io' }, status: :unprocessable_entity
    end
  end

  def import_content_fee
    if params[:file].present?
      S3FileImportWorker.perform_async('Importers::IoContentFeesService',
                                      company.id,
                                      params[:file][:s3_file_path],
                                      params[:file][:original_filename])
      render json: {
          message: import_success_message
      }, status: :ok
    end
  end

  def import_costs
    if params[:file].present?
      S3FileImportWorker.perform_async('Importers::IoCostsService',
                                      company.id,
                                      params[:file][:s3_file_path],
                                      params[:file][:original_filename])
      render json: {
          message: import_success_message
      }, status: :ok
    end
  end

  def export_costs
    respond_to do |format|
      format.csv {
        require 'timeout'
        Timeout::timeout(300) {
          send_data io_costs_csv, filename: "io-costs-#{Date.today}.csv"
        }
      }
    end
  end

  private

  def import_success_message
    @_import_success_message ||= 'Your file is being processed.
      Please check status at Import Status tab in a few minutes (depending on the file size)'
  end

  def io_params
    params.require(:io).permit(
      :name,
      :budget,
      :budget_loc,
      :curr_cd,
      :start_date,
      :end_date,
      :advertiser_id,
      :agency_id,
      :io_number,
      :external_io_number,
      :deal_id,
      :freezed
    )
  end

  def ios
    ios_by_name
      .union(ios_by_agency)
      .union(ios_by_advertiser)
      .includes(:currency, :deal, :agency, :advertiser)
      .by_start_date(params[:start_date], params[:end_date])
      .by_agency_id(params[:agency_id])
      .by_advertiser_id(params[:advertiser_id])
      .limit(limit)
      .offset(offset)
  end

  def io_costs_csv
    Csv::IoCostService.new(company, cost_monthly_amounts).perform
  end

  def cost_monthly_amounts
    company.cost_monthly_amounts.includes(
        cost: {
          io: [
            :io_members, 
            :users
          ], 
          product: {}, 
          values: :option
        }
      )
  end

  def io
    @io ||= company.ios.find(params[:id])
  end

  def company
    current_user.company
  end

  def company_ios
    @_company_ios ||= company.ios
  end

  def ios_by_agency
    company_ios.by_agency_name(params[:name])
  end

  def ios_by_advertiser
    company_ios.by_advertiser_name(params[:name])
  end

  def ios_by_name
    company_ios.by_name(params[:name])
  end
end
