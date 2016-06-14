@app.controller 'ForecastsDetailController',
['$scope', '$q', 'Forecast', 'Revenue', 'DealResource',
($scope, $q, Forecast, Revenue, DealResource) ->
  $scope.years = [2016, 2017]
  $scope.deals = []
  $scope.stages = []
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
        $scope.revenues[revenue.id] = revenue
        for n in [1..4]
          delivered = revenue.delivered * revenue.quarters[n-1]
          $scope.revenuesByQuarter[revenue.year][n] += delivered
          $scope.forecastsByQuarter[revenue.year][n] += delivered
          $scope.forecastsByYear[revenue.year] += delivered

  $q.all(forecastRequests).then (responses) ->
    responses.forEach (response) ->
      response[0].teams.forEach (team) ->
        if not $scope.stages.length
          team.stages.sort((a, b) ->
            b.probability - a.probability
          ).forEach (stage) ->
            $scope.stages.push stage
            $scope.stagesById[stage.id] = stage

        continue if not team or not team.year or not team.quarter

        if not $scope.forecastsByStage[team.year].stages
          $scope.forecastsByStage[team.year] = {stages: {}}
          $scope.unweightedByStage[team.year] = {stages: {}}
          for stage in $scope.stages
            $scope.forecastsByStage[team.year].stages[stage.id] = {
              1: 0,
              2: 0,
              3: 0,
              4: 0,
              probability: stage.probability
            }
            $scope.unweightedByStage[team.year].stages[stage.id] = {
              1: 0,
              2: 0,
              3: 0,
              4: 0,
              probability: stage.probability
            }
        $scope.quotasByQuarter[team.year][team.quarter] += parseFloat(team.quota)
        $scope.quotasByYear[team.year] += parseFloat(team.quota)
        for stageId, pipeline of team.weighted_pipeline_by_stage
          $scope.forecastsByStage[team.year].stages[stageId][team.quarter] += parseFloat(pipeline)
          $scope.forecastsByQuarter[team.year][team.quarter] += parseFloat(pipeline)
          $scope.forecastsByYear[team.year] += parseFloat(pipeline)
        for stageId, pipeline of team.unweighted_pipeline_by_stage
          $scope.unweightedByStage[team.year].stages[stageId][team.quarter] += parseFloat(pipeline)
          $scope.unweightedByQuarter[team.year][team.quarter] += parseFloat(pipeline)
          $scope.unweightedByYear[team.year] += parseFloat(pipeline)

  DealResource.query(year: $scope.years[0]).$promise.then (deals) ->
    deals.sort (a, b) ->
      b.stage.probability - a.stage.probability
    $scope.deals = deals
]
