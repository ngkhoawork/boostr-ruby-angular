class Api::Publishers::ShowSerializer < Api::Publishers::Serializer
  attributes :publisher_stage_id, :type_id, :fill_rate, :revenue_lifetime, :revenue_ytd, :contacts, :renewal_term_id,
             :publisher_custom_field_obj, :address

  def fill_rate
    return 0 if fill_rate_sum.zero?

    (fill_rate_sum / object.daily_actuals_for_previous_month.size).round(1)
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

  def fill_rate_sum
    @_fill_rate_sum ||= object.daily_actuals_for_previous_month.sum(:fill_rate).to_f
  end
end
