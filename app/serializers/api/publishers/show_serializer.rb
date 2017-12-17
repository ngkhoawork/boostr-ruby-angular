class Api::Publishers::ShowSerializer < Api::Publishers::Serializer
  attributes :publisher_stage_id, :type_id, :fill_rate, :revenue_lifetime, :revenue_ytd, :contacts, :renewal_term_id,
             :publisher_custom_field_obj, :address

  def fill_rate
    return 0 if sum_of_filled_impressions.zero?

    (sum_of_available_impressions / sum_of_filled_impressions * 100).round(1)
  end

  def revenue_lifetime
    object.daily_actuals.sum(:total_revenue)
  end

  def revenue_ytd
    object.daily_actuals_for_current_year.sum(:total_revenue)
  end

  def contacts
    object.contacts.includes(:primary_client_contact, :address, :client).map do |contact|
      Api::Publishers::ContactsSerializer.new(contact).as_json
    end
  end

  def publisher_custom_field_obj
    object.publisher_custom_field
  end

  has_one :publisher_custom_field

  private

  def daily_actuals_for_previous_month
    @_daily_actuals_for_previous_month ||=
      object.daily_actuals.by_date(previous_month.beginning_of_month, previous_month.end_of_month)
  end

  def daily_actuals_for_current_year
    @_daily_actuals_for_current_year ||= object.daily_actuals.by_date(current_date.beginning_of_year, current_date)
  end

  def current_date
    @_current_month ||= Date.today
  end

  def previous_month
    @_previous_month ||= current_date - 1.month
  end

  def sum_of_available_impressions
    daily_actuals_for_previous_month.sum(:available_impressions)
  end

  def sum_of_filled_impressions
    daily_actuals_for_previous_month.sum(:filled_impressions)
  end
end
