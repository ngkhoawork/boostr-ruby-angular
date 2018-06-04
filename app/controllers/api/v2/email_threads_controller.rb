class  Api::V2::EmailThreadsController < ApiController
  respond_to :json

  def all_threads
    if params[:thread_ids].present?
      email_threads = current_user.email_threads.thread_list current_user.id, params[:thread_ids]

      render json: { threads: email_threads }
    else
      render json: { errors: 'Need provide array of thread_ids' }, status: :unprocessable_entity
    end
  end

  def create_thread
    if params[:gmail_query_string]
      email_thread = EmailThread.create(decorated_email_threads)

      if email_thread.save
        render json: email_thread
      else

        render json: { errors: email_thread.errors.messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: "Please provide gmail_query_string param" }, status: :unprocessable_entity
    end
  end

  def all_opens
    if email_thread
      render json: email_thread.email_opens
    else
      render json: { errors: "Email Thread Not Found" }, status: 404
    end
  end

  def all_emails
    threads = current_user.email_threads.search_by_email_threads(email_thread_params[:search]).order('created_at DESC')

    render json: threads.limit(limit).offset(offset).as_json({ include: :last_five_opens })
  end

  def all_not_opened_emails
    render json: current_user
                  .email_threads
                  .without_opens
                  .search_by_email_threads(email_thread_params[:search]).order('email_threads.created_at DESC').limit(limit).offset(offset)
  end

  private

  def email_thread
    current_user.email_threads.find_by_thread_id(params[:email_thread_id])
  end

  def decorated_email_threads
    Emails::EmailThreadDecorator.new(email_thread_params, current_user).collect
  end

  def email_thread_params
    params.permit(
      :thread_id,
      :email_guid,
      :search,
      gmail_query_string:
        [
          :subject,
          :from,
          :body,
          to: []
        ]
    )
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end