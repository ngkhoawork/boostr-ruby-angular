@app.controller "InfluencersNewController",
['$scope', '$rootScope', '$modalInstance', 'Influencer', 'Field', 'influencer'
($scope, $rootScope, $modalInstance, Influencer, Field, influencer) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.influencer = { active: true }

  Field.defaults($scope.influencer, 'Influencer').then (fields) ->
    $scope.influencer.network = Field.field($scope.influencer, 'Network')

  $scope.submitForm = () ->
    $scope.errors = {}

    if !$scope.influencer.name then $scope.errors['name'] = 'Name is required'
    if !$scope.influencer.network.option_id then $scope.errors['network'] = 'Network is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    Influencer.create(influencer: $scope.influencer).then(
      (influencer) ->
        $rootScope.$broadcast 'newInfluencer', influencer
        $modalInstance.close(influencer)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
