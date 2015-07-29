@app.controller 'RevenueController',
['$scope', '$modal', 'Revenue',
($scope, $modal, Revenue) ->

  $scope.init = ->
    Revenue.all (revenue) ->
      $scope.revenue = revenue

  $scope.showUploadModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/revenue_upload.html'
      size: 'lg'
      controller: 'RevenueUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_revenues', ->
    $scope.init()

  $scope.init()
]