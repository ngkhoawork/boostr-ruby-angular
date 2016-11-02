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
      }
    } )
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
        }
      } )
    else
      render json: { errors: io.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def io_params
    params.require(:io).permit(:name, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :io_number, :external_io_number)
  end

  def ios
    company.ios
  end

  def io
    @io ||= ios.find(params[:id])
  end

  def company
    current_user.company
  end
end
