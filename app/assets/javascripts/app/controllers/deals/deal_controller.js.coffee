@app.controller 'DealController',
['$scope', '$routeParams', '$modal', 'Deal',
($scope, $routeParams, $modal, Deal) ->

  $scope.init = ->
    $scope.currentDeal = {}
    Deal.all().then (deals) ->
      Deal.set( $routeParams.id )

  $scope.$on 'updated_current_deal', ->
    $scope.currentDeal = Deal.get()

  $scope.init()
]
