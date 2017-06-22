@app.controller "InfluencerContentFeesNewController",
['$scope', '$rootScope', '$modalInstance', 'Influencer', 'InfluencerContentFee', 'Currency', 'CurrentUser', 'io'
($scope, $rootScope, $modalInstance, Influencer, InfluencerContentFee, Currency, CurrentUser, io) ->

  $scope.formType = "Assign"
  $scope.submitText = "Assign"
  $scope.influencerContentFee = { }
  $scope.io = io
  $scope.contentFees = io.content_fees
  $scope.query = ""
  $scope.feeTypes = [
    {name: 'Flat', value: 'flat'},
    {name: '%', value: 'percentage'}
  ]

  init = ->
    $scope.searchInfluencers('')
    getCurrencies()

  getCurrencies = ->
    Currency.active_currencies().then (currencies) ->
      $scope.currencies = currencies
      setDefaultCurrency()

  setDefaultCurrency = ->
    curr_cd = 'USD'
    curr_cd = $scope.io.curr_cd if $scope.io.curr_cd
    $scope.influencerContentFee.curr_cd = curr_cd
    
  $scope.influencerSelected = (influencerId) ->
    influencer = _.find($scope.influencers, {id: influencerId})
    $scope.influencerContentFee.fee_type = influencer.agreement.fee_type if influencer && influencer.agreement

  $scope.searchInfluencers = (name) ->
    params = {
      name: name
    }
    Influencer.all(params).then (influencers) ->
      $scope.influencers = influencers
  $scope.submitForm = () ->
    $scope.errors = {}

    if !$scope.influencerContentFee.influencer_id then $scope.errors['influencer'] = 'Influencer is required'
    if !$scope.influencerContentFee.effect_date then $scope.errors['effect_date'] = 'Date is required'
    if !$scope.influencerContentFee.content_fee_id then $scope.errors['content_fee'] = 'Product is required'
    if !$scope.influencerContentFee.curr_cd then $scope.errors['currency'] = 'Currency is required'
    if !$scope.influencerContentFee.gross_amount_loc then $scope.errors['gross_amount'] = 'Gross amount is required'
    if !$scope.influencerContentFee.fee_type then $scope.errors['fee_type'] = 'Fee Type is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    InfluencerContentFee.create(io_id: $scope.io.id, influencer_content_fee: $scope.influencerContentFee).then(
      (influencerContentFee) ->
        $modalInstance.close(influencerContentFee)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.dismiss()

  init()
]
