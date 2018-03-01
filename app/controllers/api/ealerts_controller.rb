class Api::EalertsController < ApplicationController
  respond_to :json

  def index
    render json: ealerts.first
    .as_json({include: {
        ealert_custom_fields:  {
          include: {
            subject: {}
          }
        },
        ealert_stages: {
          include: {
            stage: {
              include: {
                sales_process: {}
              }
            }
          }
        }
      }
    })
  end

  def create
    ealert = ealerts.new(ealert_params)

    if ealert.save
      render json: ealert.as_json({include: {
          ealert_custom_fields: {
            include: {
              subject: {}
            }
          },
          ealert_stages: {
            include: {
              stage: {}
            }
          }
        }
      }), status: :created
    else
      render json: { errors: ealert.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: ealert.as_json({include: {
        ealert_custom_fields: {
          include: {
            subject: {}
          }
        },
        ealert_stages: {
          include: {
            stage: {}
          }
        }
      }
    })
  end

  def update
    if ealert.update_attributes(ealert_params)
      render json: ealert.as_json({include: {
          ealert_custom_fields: {
            include: {
              subject: {}
            }
          },
          ealert_stages: {
            include: {
              stage: {}
            }
          }
        }
      }), status: :accepted
    else
      render json: { errors: ealert.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    ealert.destroy

    render nothing: true
  end

  def send_ealert
    recipients = params[:data][:recipients].split(',').map(&:strip)
    deal_id = params[:data][:deal_id]
    comment = params[:data][:comment]
    deal = company.deals.find(deal_id)
    ealert = ealerts.find(params[:id])
    if ealert.present? && deal.present?
      UserMailer.ealert_email(recipients, params[:id], deal_id, comment, current_user.id).deliver_now
      render nothing: true
    else
      render json: { errors: ealert.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def ealert
    @ealert ||= company.ealerts.find(params[:id])
  end

  def ealert_params
    params.require(:ealert).permit(
      :company_id,
      :recipients,
      :automatic_send,
      :same_all_stages,
      :delay,
      :show_billing_contact,
      :budget,
      :flight_date,
      :agency,
      :deal_type,
      :source_type,
      :next_steps,
      :closed_reason,
      :intiative,
      :product_name,
      :product_budget,
      {
        ealert_custom_fields_attributes: [:id, :company_id, :subject_type, :subject_id, :position],
        ealert_stages_attributes: [:id, :company_id, :stage_id, :recipients, :enabled]
      }
    )
  end

  def ealerts
    @ealerts ||= company.ealerts
  end

  def deal_custom_field_names
    @deal_custom_field_names ||= company.deal_custom_field_names
  end

  def company
    @company ||= current_user.company
  end
end
