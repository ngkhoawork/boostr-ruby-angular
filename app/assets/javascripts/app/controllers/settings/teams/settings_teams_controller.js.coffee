@app.controller 'SettingsTeamsController',
['$scope', '$modal', '$location', 'Team',
($scope, $modal, $location, Team) ->

  $scope.init = () ->
    Team.all().then (teams) ->
      $scope.teams = teams

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/team_form.html'
      size: 'lg'
      controller: 'NewTeamsController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_teams', ->
    $scope.init()

  $scope.go = (path) ->
    $location.path(path)

  $scope.init()

]
