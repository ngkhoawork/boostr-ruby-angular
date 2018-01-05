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

    transformData  = (data) ->
      _.each data, (d) ->
        if !d.publisher_custom_field
          d.publisher_custom_field = []
          _.each $scope.publisherCustomFields, (cf) ->
            d.publisher_custom_field.push({field_type: "datetime", field_value: ""})
      data

    getCustomFields = (data) ->
      _.each data, (d) ->
        if d.publisher_custom_field
          $scope.publisherCustomFields = _.pluck(d.publisher_custom_field, 'field_label')
        
    getReport = (query) ->
      Publisher.publisherReport(query).then (data) ->
        getCustomFields(data)
        trasformed = transformData(data)
        $scope.showDashboard = true
        $scope.publishers = trasformed

    $scope.export = ->
      url = '/api/publishers/all_fields_report.csv'
      $window.open url + '?' + $httpParamSerializer appliedFilter
      return

    $scope.init()
  ]