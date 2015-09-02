@app.controller 'SettingsTeamController',
['$scope', '$modal', '$location', '$routeParams', 'Team', 'User',
($scope, $modal, $location, $routeParams, Team, User) ->

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
    User.all(true)

  $scope.go = (path) ->
    $location.path(path)

  $scope.delete = (team) ->
    if confirm('Are you sure you want to delete "' +  team.name + '"?')
      Team.delete team, ->
        $location.path("/settings/teams/" + $routeParams.id)

  $scope.init()

]
