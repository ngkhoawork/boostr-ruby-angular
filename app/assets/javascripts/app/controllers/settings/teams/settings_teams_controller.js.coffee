@app.controller 'SettingsTeamsController',
['$scope', '$modal', '$location', 'Team', 'User',
($scope, $modal, $location, Team, User) ->

  $scope.init = () ->
    Team.all(root_only: true).then (teams) ->
      $scope.teams = teams

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/team_form.html'
      size: 'lg'
      controller: 'NewTeamsController'
      backdrop: 'static'
      keyboard: false
      resolve:
        team: ->
          {}

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
        $location.path('/settings/teams')

  $scope.init()

]
