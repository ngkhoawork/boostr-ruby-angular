class Api::IosController < ApplicationController
  respond_to :json

  def index
    render json: ios
  end

  def show
    render json: io.as_json( include: {
      io_members: {
        methods: [
          :name
        ]
      },
      content_fees: {
        include: {
          content_fee_product_budgets: {}
        },
        methods: [
          :product
        ]
      },
      display_line_items: {
        methods: [
          :product
        ]
      },
      print_items: {}
    } )
  end

  def create
    io = company.ios.new(io_params)
    if io.deal_id
      io.io_number = io.deal_id
    elsif io.external_io_number
      io.io_number = io.external_io_number
    else

    end
    if io.save
      render json: io, status: :created
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if io.update_attributes(io_params)
      render json: io.as_json( include: {
        io_members: {
          methods: [
            :name
          ]
        },
        content_fees: {
          include: {
            content_fee_product_budgets: {}
          },
          methods: [
            :product
          ]
        },
        display_line_items: {
          methods: [
            :product
          ]
        },
        print_items: {}
      } )
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def io_params
    params.require(:io).permit(:name, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :io_number, :external_io_number, :deal_id)
  end

  def ios
    if params[:page] && params[:page].to_i > 0
      offset = (params[:page].to_i - 1) * 10
      if params[:name]
        company.ios.where("name ilike ?", "%#{params[:name]}%").limit(10).offset(offset)
      else
        company.ios.limit(10).offset(offset)
      end
    else
      if params[:name]
        company.ios.where("name ilike ?", "%#{params[:name]}%")
      else
        company.ios
      end
    end
  end


  def io
    @io ||= ios.find(params[:id])
  end

  def company
    current_user.company
  end
end
