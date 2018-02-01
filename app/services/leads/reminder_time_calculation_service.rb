class Leads::ReminderTimeCalculationService
  def determine_notifications_reminder_time
    # When Time now is friday and sunday is holiday sending time is on tuesday
    return 4.day.from_now if Date.today.friday? && holiday?(2.day.from_now)

    # When Time now is friday sending time is on monday
    return 3.day.from_now if Date.today.friday?

    # When Time now is saturday sending time is on tuesday
    return 3.day.from_now if Date.today.saturday?

    # When Time now is sunday sending time is on tuesday
    return 2.day.from_now if Date.today.sunday?

    # When Time now is thursday and sunday is holiday sending time is on monday
    return 4.day.from_now if Date.today.thursday? && holiday?(1.day.from_now)

    holiday?(1.day.from_now) ? 2.day.from_now : 1.day.from_now
  end

  def determine_notifications_reassignment_time
    # When Time now is friday and sunday is holiday sending time is on wednesday
    return 5.day.from_now if Date.today.friday? && holiday?(2.day.from_now)

    # When Time now is friday sending time is on tuesday
    return 4.day.from_now if Date.today.friday?

    # When Time now is saturday sending time is on wednesday
    return 4.day.from_now if Date.today.saturday?

    # When Time now is sunday sending time is on wednesday
    return 3.day.from_now if Date.today.sunday?

    # When Time now is thursday sending time is on monday
    return 4.day.from_now if Date.today.thursday?

    # When Time now is wednesday and sunday is holiday sending time is on monday
    return 5.day.from_now if Date.today.wednesday && holiday?(2.day.from_now)

    holiday?(2.day.from_now) ? 3.day.from_now : 2.day.from_now
  end

  private

  def current_year
    @_current_year ||= Date.today.year.to_s
  end

  def holidays
    [
      '1 January ',
      '15 January ',
      '19 February ',
      '28 May ',
      '4 July ',
      '3 September ',
      '8 October ',
      '11 November ',
      '22 November ',
      '25 December '
    ]
  end

  def holiday?(date)
    holidays.map { |day| day.concat(current_year).to_time }.include? date
  end
end
