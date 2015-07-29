@app.controller 'DealsController',
['$scope', '$modal', 'Deal',
($scope, $modal, Deal) ->

  $scope.init = ->
    Deal.all (deals) ->
      $scope.deals = deals
    $scope.stages = Deal.stages()

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'lg'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_deals', ->
    $scope.init()

  $scope.init()
]