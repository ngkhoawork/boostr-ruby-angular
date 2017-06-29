@app.controller "InfluencersEditController",
['$scope', '$rootScope', '$modalInstance', 'Influencer', 'Field', 'CountriesList', 'influencer'
($scope, $rootScope, $modalInstance, Influencer, Field, CountriesList, influencer) ->
  
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.influencer = influencer
  $scope.feeTypes = [
    {name: 'Flat', value: 'flat'},
    {name: '%', value: 'percentage'}
  ]

  $scope.showAddressFields = Boolean($scope.influencer.address and
          ($scope.influencer.address.country or
              $scope.influencer.address.street1 or
              $scope.influencer.address.city or
              $scope.influencer.address.state or
              $scope.influencer.address.zip))

  CountriesList.get (data) ->
    $scope.countries = data.countries

  Field.defaults($scope.influencer, 'Influencer').then (fields) ->
    $scope.influencer.network = Field.field($scope.influencer, 'Network')

  $scope.submitForm = () ->
    $scope.errors = {}

    if !$scope.influencer.name then $scope.errors['name'] = 'Name is required'
    if !$scope.influencer.network.option_id then $scope.errors['network'] = 'Network is required'
    if !$scope.influencer.agreement.fee_type then $scope.errors['fee_type'] = 'Agreement fee type is required'
    if !$scope.influencer.agreement.amount then $scope.errors['amount'] = 'Agreement amount is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    Influencer.update(id: $scope.influencer.id, influencer: $scope.influencer).then(
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
