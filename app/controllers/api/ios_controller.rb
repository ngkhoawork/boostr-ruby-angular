class Api::IosController < ApplicationController
  respond_to :json

  def index
    if params[:filter] == 'upside'
      render json: display_line_items.where("balance > 0").as_json( include: {
          io: {
              include: {
                  advertiser: {},
                  agency: {}
              }
          }
      })
    elsif params[:filter] == 'risk'
      render json: display_line_items.where("balance < 0").as_json( include: {
          io: {
              include: {
                  advertiser: {},
                  agency: {}
              }
          }
      })
    elsif params[:filter] == 'programmatic'
      render json: []
    else
      render json: ios
    end

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
    params.require(:io).permit(:name, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :io_number, :external_io_number)
  end

  def ios
    company.ios
  end

  def io
    @io ||= ios.find(params[:id])
  end

  def display_line_items
    member_ids = [current_user.id]
    if current_user.leader?
      member_ids += current_user.teams.first.all_members.collect{|m| m.id}
      member_ids += current_user.teams.first.all_leaders.collect{|m| m.id}
    end
    io_ids = Io.joins(:io_members).where("io_members.user_id in (?)", member_ids.uniq).all.collect{|io| io.id}.uniq
    DisplayLineItem.where("io_id in (?)", io_ids)
  end

  def company
    current_user.company
  end
end
