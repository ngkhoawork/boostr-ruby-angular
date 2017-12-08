class Api::Publishers::ShowSerializer < Api::Publishers::Serializer
  attributes :publisher_stage_id, :type_id, :fill_rate, :revenue_lifetime, :revenue_ytd, :contacts,
             :publisher_custom_field_obj, :address

  def fill_rate
    daily_actuals_for_current_month.sum(:fill_rate) / daily_actuals_for_current_month.count rescue 0
  end

  def revenue_lifetime
    daily_actuals_for_current_month.sum(:total_revenue)
  end

  def revenue_ytd
    daily_actuals_for_current_year.sum(:total_revenue)
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

  def daily_actuals_for_current_month
    @_daily_actuals_for_current_month ||=
      object.daily_actuals.by_date(current_date.beginning_of_month, current_date.end_of_month)
  end

  def daily_actuals_for_current_year
    @_daily_actuals_for_current_year ||= object.daily_actuals.by_date(current_date.beginning_of_year, current_date)
  end

  def current_date
    @_current_month ||= Date.today
  end
end
