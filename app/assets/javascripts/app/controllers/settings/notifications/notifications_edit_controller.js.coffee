@app.controller 'NotificationsEditController',
['$scope', '$modalInstance', '$q', '$filter', 'Notification', 'notification', 'User'
($scope, $modalInstance, $q, $filter, Notification, notification, User) ->

  $scope.formType = 'Edit'
  $scope.submitText = 'Update'

  $scope.init = () ->
    $scope.notification = notification
    
  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Notification.update(id: $scope.notification.id, notification: $scope.notification).then (notification) ->
      $scope.notification = notification
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
