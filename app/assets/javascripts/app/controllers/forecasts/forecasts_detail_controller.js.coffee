@app.controller 'ForecastsDetailController',
['$scope', '$q', 'Forecast', 'Revenue', 'DealResource', 'CurrentUser', 'TimePeriod'
($scope, $q, Forecast, Revenue, DealResource, CurrentUser, TimePeriod) ->
  $scope.years = [2017]
  $scope.deals = []
  $scope.stagesById = {}
  $scope.revenueRequests = []

  $scope.quotasByQuarter = {}
  $scope.quotasByYear = {}
  $scope.revenues = {}
  $scope.revenuesByQuarter = {}
  $scope.unweightedByStage = {}
  $scope.unweightedByQuarter = {}
  $scope.unweightedByYear = {}
  $scope.forecastsByStage = {}
  $scope.forecastsByQuarter = {}
  $scope.forecastsByYear = {}

  $scope.showQuarterlyDeals = true

  $scope.years.forEach (year) ->
    $scope.revenues[year] = {}
    $scope.quotasByQuarter[year] = {
      1: 0,
      2: 0,
      3: 0,
      4: 0
    }
    $scope.quotasByYear[year] = 0
    $scope.revenuesByQuarter[year] = {
      1: 0,
      2: 0,
      3: 0,
      4: 0
    }
    $scope.unweightedByStage[year] = { stages: {} }
    $scope.unweightedByQuarter[year] = {
      1: 0,
      2: 0,
      3: 0,
      4: 0
    }
    $scope.unweightedByYear[year] = 0
    $scope.forecastsByStage[year] = { stages: {} }
    $scope.forecastsByQuarter[year] = {
      1: 0,
      2: 0,
      3: 0,
      4: 0
    }
    $scope.forecastsByYear[year] = 0

  TimePeriod.current_year_quarters().then (timePeriods) ->
    $scope.forecast_time_periods = timePeriods

    CurrentUser.get().$promise.then (user) ->
      if user.company_id is 5
        $scope.executeRequests()

  $scope.executeRequests = () ->
    Forecast.query({ time_period_id: $scope.forecast_time_periods[0].id }).$promise.then (response) ->
      processForecastResponse(response)
      Forecast.query({ time_period_id: $scope.forecast_time_periods[1].id }).$promise.then (response) ->
        processForecastResponse(response)
        Forecast.query({ time_period_id: $scope.forecast_time_periods[2].id }).$promise.then (response) ->
          processForecastResponse(response)
          Forecast.query({ time_period_id: $scope.forecast_time_periods[3].id }).$promise.then (response) ->
            processForecastResponse(response)

            DealResource.query(year: $scope.years[0]).$promise.then (deals) ->
              deals.sort (a, b) ->
                b.stage.probability - a.stage.probability
              $scope.deals = deals

    $scope.years.forEach (year) ->
      Revenue.get(year: year).$promise.then (revenues) ->
        processRevenueResponse(revenues)

  processForecastResponse = (response) ->
    response[0].teams.forEach (team) ->
      team.stages.forEach (stage) ->
        if not $scope.stagesById[stage.id]
          $scope.years.forEach (year) ->
            $scope.forecastsByStage[year].stages[stage.id] = {
              1: 0,
              2: 0,
              3: 0,
              4: 0,
              probability: stage.probability
            }
            $scope.unweightedByStage[year].stages[stage.id] = {
              1: 0,
              2: 0,
              3: 0,
              4: 0,
              probability: stage.probability
            }
          $scope.stagesById[stage.id] = stage

      return if not team or not team.year_value or not team.quarter_number

      $scope.revenuesByQuarter[team.year_value][team.quarter_number] += team.revenue
      $scope.forecastsByQuarter[team.year_value][team.quarter_number] += team.revenue
      $scope.forecastsByYear[team.year_value] += team.revenue
      $scope.unweightedByQuarter[team.year_value][team.quarter_number] += team.revenue
      $scope.unweightedByYear[team.year_value] += team.revenue

      $scope.quotasByQuarter[team.year_value][team.quarter_number] += parseFloat(team.quota)
      $scope.quotasByYear[team.year_value] += parseFloat(team.quota)
      for stageId, pipeline of team.weighted_pipeline_by_stage
        $scope.forecastsByStage[team.year_value].stages[stageId][team.quarter_number] += pipeline
        $scope.forecastsByQuarter[team.year_value][team.quarter_number] += pipeline
        $scope.forecastsByYear[team.year_value] += pipeline
      for stageId, pipeline of team.unweighted_pipeline_by_stage
        $scope.unweightedByStage[team.year_value].stages[stageId][team.quarter_number] += pipeline
        $scope.unweightedByQuarter[team.year_value][team.quarter_number] += pipeline
        $scope.unweightedByYear[team.year_value] += pipeline

  processRevenueResponse = (revenues) ->
    revenues.forEach (revenue) ->
      if $scope.revenues[revenue.year] && $scope.revenues[revenue.year][revenue.advertiser.id]
        $scope.revenues[revenue.year][revenue.advertiser.id].budget += revenue.budget
      else
        $scope.revenues[revenue.year][revenue.advertiser.id] = revenue
        $scope.revenues[revenue.year][revenue.advertiser.id].month_amounts = []
        $scope.revenues[revenue.year][revenue.advertiser.id].quarter_amounts = []
        for n in [1..12]
          $scope.revenues[revenue.year][revenue.advertiser.id].month_amounts[n-1] = 0
        for n in [1..4]
          $scope.revenues[revenue.year][revenue.advertiser.id].quarter_amounts[n-1] = 0

      for n in [1..12]
        budget = parseFloat(revenue.months[n-1])
        $scope.revenues[revenue.year][revenue.advertiser.id].month_amounts[n-1] += budget
      for n in [1..4]
        budget = parseFloat(revenue.quarters[n-1])
        $scope.revenues[revenue.year][revenue.advertiser.id].quarter_amounts[n-1] += budget
]
