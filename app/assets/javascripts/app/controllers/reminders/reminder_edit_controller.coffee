@app.controller 'ReminderEditController',
  ['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'itemId', 'itemType'
    ($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, itemId, itemType) ->

      $scope.showMeridian = true

      $scope.init = ->
        $scope.formType = 'New'
        $scope.submitText = 'Set Reminder'
        $scope.itemId = itemId
        $scope.itemType = itemType

      $scope.submitForm = () ->
        console.log('I am a submit')

      $scope.cancel = ->
        $modalInstance.close()

      $scope.init()
  ]
