@app.controller 'SettingsUsersController',
['$scope', '$modal', 'User',
($scope, $modal, User) ->

  $scope.init = () ->
    User.all().then (users) ->
      $scope.users = users

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_form.html'
      size: 'lg'
      controller: 'NewUsersController'
      backdrop: 'static'
      keyboard: false

  $scope.init()

]