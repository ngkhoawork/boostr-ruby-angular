@app.controller 'PublishersReportController',
  ['$scope', 'Team', 'Publisher', '$httpParamSerializer', '$window', ($scope, Team, Publisher, $httpParamSerializer, $window) ->
    $scope.teams = []
    $scope.stages = []
    appliedFilter = null

    $scope.init = ->
      $scope.getTeams()
      $scope.getStages()

    $scope.getTeams = ->
      Team.all(all_teams: true).then (teams) ->
        $scope.teams = teams

    $scope.getStages = ->
      Publisher.publisherSettings().then (settings) ->
        $scope.stages = settings.publisher_stages

    $scope.onFilterApply = (query) ->
      console.log(query)
      appliedFilter = query
      getReport query

    getReport = (query) ->
      Publisher.publisherReport(query).then (data) ->
        console.log(data)

    $scope.export = ->
      url = '/api/publishers/all_fields_report.csv'
      $window.open url + '?' + $httpParamSerializer appliedFilter
      return

    $scope.init()
  ]