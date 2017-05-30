class ActivitySummary::BaseService
  def initialize(user, options = {})
    @user = user
    @params = options.fetch(:params)
  end

  private

  attr_reader :user, :params

  def company
    @_company ||= user.company
  end

  def start_date
    @_start_date ||= (params[:start_date] ? Date.parse(params[:start_date]) : (Time.now.end_of_day - 30.days))
  end

  def end_date
    @_end_date ||= (params[:end_date] ? Date.parse(params[:end_date]).end_of_day : Time.now.end_of_day)
  end
end
