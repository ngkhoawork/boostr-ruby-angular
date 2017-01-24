@app.controller 'SettingsUsersController',
['$scope', '$modal', 'User', 'Currency', 'CurrentUser',
($scope, $modal, User, Currency, CurrentUser) ->
  $scope.user_types = User.user_types_list
  $scope.user_statuses = User.user_statuses_list

  $scope.init = () ->
    Currency.active_currencies().then (currencies) ->
      $scope.currencies = currencies
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
