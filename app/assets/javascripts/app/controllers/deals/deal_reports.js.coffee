@app.controller 'DealReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', 'Deal',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, Deal) ->

      $scope.init = ->
       $q.all({ dealData: Deal.pipeline_report({filter: 'company'}) }).then (data) ->
         $scope.deals = data.dealData[0].deals
         $scope.productRange = data.dealData[0].range

      $scope.findDealProductBudget = (dealProducts, productTime) ->
        result =  _.find dealProducts, (dealProduct) ->
          if (dealProduct.start_date == productTime)
            return dealProduct
        if result
          return result.budget
        else
          return 0

      $scope.exportReports = ->
        $window.open('/api/deals/pipeline_report.csv')
        return true

  ]
