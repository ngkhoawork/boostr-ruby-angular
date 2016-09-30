@app.controller 'SettingsUsersController',
['$scope', '$modal', 'User', 'CurrentUser',
($scope, $modal, User, CurrentUser) ->
  $scope.user_statuses = User.user_statuses_list
  $scope.user_types = [
    { name: 'Default', id: 0 }
    { name: 'Seller', id: 1 }
    { name: 'Sales Manager', id: 2 }
    { name: 'Account Manager', id: 3 }
    { name: 'Manager Account Manager', id: 4 }
    { name: 'Admin', id: 5 }
    { name: 'Exec', id: 6 }
  ]

  $scope.init = () ->
    User.query().$promise.then (users) ->
      $scope.users = users
    CurrentUser.get().$promise.then (user) ->
      $scope.current_user = user

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

  $scope.submitUser = (user) ->
    user.$update()

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
