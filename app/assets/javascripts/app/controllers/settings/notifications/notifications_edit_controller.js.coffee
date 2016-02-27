@app.controller 'NotificationsEditController',
['$scope', '$modalInstance', '$q', '$filter', 'Notification', 'notification', 'User'
($scope, $modalInstance, $q, $filter, Notification, notification, User) ->

  $scope.formType = 'Edit'
  $scope.submitText = 'Update'

  $scope.init = () ->
    $scope.notification = notification
    
  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    if $scope.notification.recipients != null && $scope.notification.recipients.trim() != '' && !$scope.validateEmails($scope.notification.recipients)
      $scope.buttonDisabled = false
      $scope.notification_form.recipients.$dirty = true
      $scope.notification_form.recipients.$setValidity('email', false)
    else
      Notification.update(id: $scope.notification.id, notification: $scope.notification).then (notification) ->
        $scope.notification = notification
        $modalInstance.close()

  $scope.validateEmails = (emails) ->
    for email in emails.split(',')
      if !$scope.validateEmail(email.trim())
        return false
    return true

  $scope.validateEmail = (email) ->
    re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    re.test(email)

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
