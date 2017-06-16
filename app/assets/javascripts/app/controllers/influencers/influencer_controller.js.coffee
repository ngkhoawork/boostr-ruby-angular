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
      Field.defaults($scope.influencer, 'Influencer').then (fields) ->
        $scope.influencer.network = Field.field($scope.influencer, 'Network')
        console.log($scope.influencer)

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

  $scope.delete = ->
    if confirm('Are you sure you want to delete the influencer "' +  $scope.influencer.name + '"?')
      Influencer.delete(id: $scope.influencer.id)
      $location.path('/influencers')

  $scope.$on 'updated_influencers', ->
    getInfluencer()

  getInfluencer()
]
