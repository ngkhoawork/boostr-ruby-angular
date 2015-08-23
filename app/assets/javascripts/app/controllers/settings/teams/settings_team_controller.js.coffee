@app.controller 'SettingsTeamController',
['$scope', '$modal', '$location', '$routeParams', 'Team',
($scope, $modal, $location, $routeParams, Team) ->

  $scope.init = ->
    $scope.currentTeam = {}
    Team.get($routeParams.id).then (team) ->
      $scope.currentTeam = team

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/team_form.html'
      size: 'lg'
      controller: 'NewTeamsController'
      backdrop: 'static'
      keyboard: false
      resolve:
        team: ->
          parent_id: $scope.currentTeam.id

  $scope.editModal = (team) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/team_form.html'
      size: 'lg'
      controller: 'TeamsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        team: ->
          team

  $scope.$on 'updated_teams', ->
    $scope.init()

  $scope.go = (path) ->
    $location.path(path)

  $scope.init()

]
