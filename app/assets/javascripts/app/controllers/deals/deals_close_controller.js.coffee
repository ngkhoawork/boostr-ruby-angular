@app.controller 'DealsCloseController',
['$scope', '$rootScope', '$routeParams', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'currentDeal',
($scope, $rootScope, $routeParams, $modalInstance, $q, $location, Deal, Client, Stage, Field, currentDeal) ->

  $scope.init = ->
    $scope.formType = "Close"
    $scope.submitText = "Submit"
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      deal_id: $routeParams.id
      months: []
    }

  $scope.submitForm = () ->
    $scope.currentDeal.closed_at = new Date()
    $scope.currentDeal.stage_id = currentDeal.stage_id
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
      $rootScope.$broadcast 'updated_deal'
      $modalInstance.close()
    
  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
