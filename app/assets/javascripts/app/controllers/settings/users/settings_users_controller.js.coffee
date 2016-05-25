@app.controller 'SettingsUsersController',
['$scope', '$modal', 'User',
($scope, $modal, User) ->

  $scope.init = () ->
    User.query().$promise.then (users) ->
      $scope.users = users

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_form.html'
      size: 'lg'
      controller: 'NewUsersController'
      backdrop: 'static'
      keyboard: false
      resolve:
        onInvite: ->
          (user) ->
            $scope.users.push(user)

  $scope.editModal = (user) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_form.html'
      size: 'lg'
      controller: 'UsersEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        user: ->
          user
 
  $scope.init()

]
