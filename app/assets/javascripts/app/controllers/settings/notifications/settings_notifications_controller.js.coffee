@app.controller 'SettingsNotificationsController',
['$scope', '$modal', 'Notification', 'User',
($scope, $modal, Notification, User) ->
  
  $scope.init = () ->
    $scope.notifications = {}
    Notification.all().then (notifications) ->
      $scope.notifications = notifications

  $scope.editModal = (notification) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/notification_form.html'
      size: 'lg'
      controller: 'NotificationsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        notification: ->
          notification

  $scope.init()
]