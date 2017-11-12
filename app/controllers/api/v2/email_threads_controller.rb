class  Api::V2::EmailThreadsController < ApiController
  skip_before_action :authenticate_token_user
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
    if params[:gmail_query_string]
      email_thread = EmailThread.create(decorated_email_threads)

      if email_thread.save
        render json: email_thread, status: :created
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
    threads = EmailThread.order('created_at DESC')

    render json: threads.limit(limit).offset(offset).as_json({ include: :last_five_opens })
  end

  def search_by
    render json: EmailThread.search_by_email_threads(email_thread_params[:term])
  end

  def all_not_opened_emails
    render json: EmailThread.without_opens
  end

  private

  def email_thread
    EmailThread.find_by_thread_id(params[:email_thread_id])
  end

  def decorated_email_threads
    Emails::EmailThreadDecorator.new(email_thread_params).collect
  end

  def email_thread_params
    params.permit(:thread_id,
                  :email_guid,
                  :gmail_query_string,
                  :term)
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end