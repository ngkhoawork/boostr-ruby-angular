class Api::MailthreadsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    if params[:guids].present?
      email_threads = EmailThread.thread_list params[:guids]

      render json: { threads: email_threads }, status: 200
    else
      render json: { errors: 'Need provide array of thread_ids' }, status: :unprocessable_entity
    end
  end

  def create_thread
    # TODO need add current user id when auth will be implemented
    email_thread = EmailThread.create(email_guid: params[:guid])

    if email_thread.save
      render json: email_thread, status: :created
    else
      render json: { errors: email_thread.errors.messages }, status: :unprocessable_entity
    end
  end

  def see_more_opens
    if params[:guid].present?
      render json: { opened_emails: EmailOpen.by_thread(params[:guid]) }, status: 200
    else
      render json: { errors: 'Need provide thread_id' }, status: :unprocessable_entity
    end
  end
end