@app.controller 'ForecastsDetailController',
['$scope', '$q', 'Forecast', 'Revenue', 'DealResource',
($scope, $q, Forecast, Revenue, DealResource) ->
  $scope.years = [2016, 2017]
  $scope.deals = []
  $scope.stagesById = {}

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

  revenueRequests = []
  $scope.years.forEach (year) ->
    revenueRequests.push Revenue.get(year: year).$promise

  forecastRequests = $scope.years.map (year) ->
    Forecast.query(year: year).$promise

  $q.all(revenueRequests).then (revenueResponses) ->
    revenueResponses.forEach (revenues) ->
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
          budget = revenue.months[n-1]
          $scope.revenues[revenue.year][revenue.advertiser.id].month_amounts[n-1] += budget
        for n in [1..4]
          budget = revenue.quarters[n-1]
          $scope.revenues[revenue.year][revenue.advertiser.id].quarter_amounts[n-1] += budget

  $q.all(forecastRequests).then (responses) ->
    responses.forEach (response) ->
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

        return if not team or not team.year or not team.quarter

        $scope.revenuesByQuarter[team.year][team.quarter] += team.revenue
        $scope.forecastsByQuarter[team.year][team.quarter] += team.revenue
        $scope.forecastsByYear[team.year] += team.revenue
        $scope.unweightedByQuarter[team.year][team.quarter] += team.revenue
        $scope.unweightedByYear[team.year] += team.revenue

        $scope.quotasByQuarter[team.year][team.quarter] += parseFloat(team.quota)
        $scope.quotasByYear[team.year] += parseFloat(team.quota)
        for stageId, pipeline of team.weighted_pipeline_by_stage
          $scope.forecastsByStage[team.year].stages[stageId][team.quarter] += pipeline
          $scope.forecastsByQuarter[team.year][team.quarter] += pipeline
          $scope.forecastsByYear[team.year] += pipeline
        for stageId, pipeline of team.unweighted_pipeline_by_stage
          $scope.unweightedByStage[team.year].stages[stageId][team.quarter] += pipeline
          $scope.unweightedByQuarter[team.year][team.quarter] += pipeline
          $scope.unweightedByYear[team.year] += pipeline

  DealResource.query(year: $scope.years[0]).$promise.then (deals) ->
    deals.sort (a, b) ->
      b.stage.probability - a.stage.probability
    deals = deals.filter (deal) ->
      deal.stage.probability < 100
    $scope.deals = deals
]
