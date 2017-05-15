module PacingDashboardHelper
  def create_time_periods_and_time_period_weeks
    create_time_periods
    create_time_period_weeks
  end

  private

  def create_time_periods
    create_current_time_period

    create_previous_time_period

    create_previous_year_time_period
  end

  def create_current_time_period
    @_current_time_period ||= create(
        :time_period,
        name: 'Q1-2017',
        period_type: 'quarter',
        visible: true,
        start_date: '1/1/2017',
        end_date: '31/3/2017',
        company: company
    )
  end

  def create_previous_time_period
    @_previous_time_period ||= create(
        :time_period,
        name: 'Q4-2016',
        period_type: 'quarter',
        visible: true,
        start_date: '1/10/2016',
        end_date: '31/12/2016',
        company: company
    )
  end

  def create_previous_year_time_period
    @_previous_year_time_period ||= create(
        :time_period,
        name: 'Q1-2016',
        period_type: 'quarter',
        visible: true,
        start_date: '1/1/2016',
        end_date: '31/3/2016',
        company: company
    )
  end

  def create_time_period_weeks
    create_time_period_weeks_for_current_quarter

    create_time_period_weeks_for_previous_quarter

    create_time_period_weeks_for_previous_year_quarter
  end

  def create_time_period_weeks_for_current_quarter
    create :time_period_week
    create :time_period_week, week: 2, start_date: '9/1/2017', end_date: '15/1/2017'
    create :time_period_week, week: 3, start_date: '16/1/2017', end_date: '22/1/2017'
    create :time_period_week, week: 4, start_date: '23/1/2017', end_date: '29/1/2017'
    create :time_period_week, week: 5, start_date: '30/1/2017', end_date: '5/2/2017'
    create :time_period_week, week: 6, start_date: '6/2/2017', end_date: '12/2/2017'
    create :time_period_week, week: 7, start_date: '13/2/2017', end_date: '19/2/2017'
    create :time_period_week, week: 8, start_date: '20/2/2017', end_date: '26/2/2017'
    create :time_period_week, week: 9, start_date: '27/2/2017', end_date: '5/3/2017'
    create :time_period_week, week: 10, start_date: '6/3/2017', end_date: '12/3/2017'
    create :time_period_week, week: 11, start_date: '13/3/2017', end_date: '19/3/2017'
    create :time_period_week, week: 12, start_date: '27/3/2017', end_date: '31/3/2017'
  end

  def create_time_period_weeks_for_previous_quarter
    create :time_period_week, week: 1, period_name: 'Q4-2016', start_date: '1/10/2016', end_date: '9/10/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 2, period_name: 'Q4-2016', start_date: '10/10/2016', end_date: '16/10/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 3, period_name: 'Q4-2016', start_date: '17/10/2016', end_date: '23/10/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 4, period_name: 'Q4-2016', start_date: '24/10/2016', end_date: '30/10/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 5, period_name: 'Q4-2016', start_date: '31/10/2016', end_date: '6/11/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 6, period_name: 'Q4-2016', start_date: '7/11/2016', end_date: '13/11/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 7, period_name: 'Q4-2016', start_date: '14/11/2016', end_date: '20/11/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 8, period_name: 'Q4-2016', start_date: '21/11/2016', end_date: '27/11/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 9, period_name: 'Q4-2016', start_date: '28/11/2016', end_date: '4/12/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 10, period_name: 'Q4-2016', start_date: '5/12/2016', end_date: '11/12/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 11, period_name: 'Q4-2016', start_date: '12/12/2016', end_date: '18/12/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 10, period_name: 'Q4-2016', start_date: '19/12/2016', end_date: '25/12/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
    create :time_period_week, week: 10, period_name: 'Q4-2016', start_date: '26/12/2016', end_date: '31/12/2016',
           period_start: '1/10/2016', period_end: '31/12/2016'
  end

  def create_time_period_weeks_for_previous_year_quarter
    create :time_period_week, week: 1, period_name: 'Q1-2016', start_date: '1/1/2016', end_date: '10/1/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 2, period_name: 'Q1-2016', start_date: '11/1/2016', end_date: '17/1/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 3, period_name: 'Q1-2016', start_date: '18/1/2016', end_date: '24/1/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 4, period_name: 'Q1-2016', start_date: '25/1/2016', end_date: '31/1/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 5, period_name: 'Q1-2016', start_date: '1/2/2016', end_date: '7/2/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 6, period_name: 'Q1-2016', start_date: '8/2/2016', end_date: '14/2/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 7, period_name: 'Q1-2016', start_date: '15/2/2016', end_date: '21/2/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 8, period_name: 'Q1-2016', start_date: '22/2/2016', end_date: '28/2/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 9, period_name: 'Q1-2016', start_date: '29/2/2016', end_date: '6/3/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 10, period_name: 'Q1-2016', start_date: '7/3/2016', end_date: '13/3/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 11, period_name: 'Q1-2016', start_date: '14/3/2016', end_date: '20/3/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 12, period_name: 'Q1-2016', start_date: '21/3/2016', end_date: '27/3/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
    create :time_period_week, week: 13, period_name: 'Q1-2016', start_date: '28/3/2016', end_date: '31/3/2016',
           period_start: '1/1/2016', period_end: '31/3/2016'
  end
end
