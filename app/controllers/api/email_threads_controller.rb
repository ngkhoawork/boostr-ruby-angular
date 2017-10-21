class Api::EmailThreadsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    if params[:thread_ids].present?
      email_threads = EmailThread.thread_list params[:thread_ids]

      render json: { threads: email_threads }
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
    if email_thread
      render json: { opens: email_thread.email_opens }
    else
      render json: { errors: "Email Thread Not Found" }, status: 404
    end
  end

  private

  def email_thread
    EmailThread.find_by_thread_id(params[:email_thread_id])
  end
end