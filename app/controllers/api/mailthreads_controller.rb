class Api::MailthreadsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    if params[:thread_ids].present?
      email_threads = EmailThread.thread_list params[:thread_ids]

      render json: { threads: email_threads }, status: 200
    else
      render json: { errors: 'Need provide array of thread_ids' }, status: :unprocessable_entity
    end
  end

  def create_thread
    # TODO need add current user id when auth will be implemented
    email_thread = EmailThread.create(email_guid: params[:guid], thread_id: params[:thread_id])

    if email_thread.save
      render json: email_thread, status: :created
    else
      render json: { errors: email_thread.errors.messages }, status: :unprocessable_entity
    end
  end

  def all_opens
    if params[:thread_id].present?
      email_thread = EmailThread.find_by_thread_id(params[:thread_id])

      if email_thread.present?
        render json: { opened_emails: email_thread.email_open }, status: 200
      else
        render json: { errors: "Email thread not found" }, status: 404
      end
    else
      render json: { errors: 'Need provide thread_id' }, status: :unprocessable_entity
    end
  end
end