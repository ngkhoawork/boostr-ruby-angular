@app.controller 'SettingsUsersController',
['$scope', '$modal',
($scope, $modal) ->

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_form.html'
      size: 'lg'
      controller: 'NewUsersController'
      backdrop: 'static'
      keyboard: false

]