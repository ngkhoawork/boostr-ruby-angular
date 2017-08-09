@app.controller "InfluencerController",
['$scope', '$rootScope', '$modal', '$routeParams', 'Influencer', 'Field'
($scope, $rootScope, $modal, $routeParams, Influencer, Field) ->

  $scope.influencer = {}
  $scope.feeTypes = [
    {name: 'Flat', value: 'flat'},
    {name: '%', value: 'percentage'}
  ]

  getInfluencer = () ->
    Influencer.get($routeParams.id).then (influencer) ->
      $scope.influencer = influencer
      if $scope.influencer.influencer_content_fees
          $scope.influencer.total_influencer_gross = 0
          $scope.influencer.total_influencer_net = 0

          _.each $scope.influencer.influencer_content_fees, (influencer_content_fee) ->
            $scope.influencer.total_influencer_gross += parseFloat(influencer_content_fee.gross_amount)
          _.each $scope.influencer.influencer_content_fees, (influencer_content_fee) ->
            $scope.influencer.total_influencer_net += parseFloat(influencer_content_fee.net)
      Field.defaults($scope.influencer, 'Influencer').then (fields) ->
        $scope.influencer.network = Field.field($scope.influencer, 'Network')

  $scope.updateInfluencer = () ->
    Influencer.update(id: $scope.influencer.id, influencer: $scope.influencer)

  $scope.showEditModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/influencer_form.html'
      size: 'md'
      controller: 'InfluencersEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        influencer: ->
          $scope.influencer

  $scope.concatAddress = (address) ->
    row = []
    if address
      if address.city then row.push address.city
      if address.state then row.push address.state
      if address.zip then row.push address.zip
      if address.country then row.push address.country
    row.join(', ')

  $scope.delete = ->
    if confirm('Are you sure you want to delete the influencer "' +  $scope.influencer.name + '"?')
      Influencer.delete(id: $scope.influencer.id)
      $location.path('/influencers')

  $scope.$on 'updated_influencers', ->
    getInfluencer()

  getInfluencer()
]
