@app.controller 'PublishersReportController',
  ['$scope', 'Team', 'Publisher', '$httpParamSerializer', '$window', ($scope, Team, Publisher, $httpParamSerializer, $window) ->
    $scope.teams = []
    $scope.stages = []
    $scope.publishers = []
    $scope.publisherCustomFields = []
    appliedFilter = null
    $scope.showDashboard = false

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
      appliedFilter = query
      getReport query

    getCustomFields = (data) ->
      _.each data, (d) ->
        $scope.publisherCustomFields = _.pluck(d.publisher_custom_field, 'field_label')
        
    getReport = (query) ->
      Publisher.publisherReport(query).then (data) ->
        getCustomFields(data)
        $scope.showDashboard = true
        $scope.publishers = data

    $scope.export = ->
      url = '/api/publishers/all_fields_report.csv'
      $window.open url + '?' + $httpParamSerializer appliedFilter
      return

    $scope.init()
  ]