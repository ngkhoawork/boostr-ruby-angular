@app.controller 'DealReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = true
      $scope.init = ->
       $q.all({ dealData: Deal.pipeline_report({filter: 'company'}) }).then (data) ->
         $scope.deals = data.dealData[0].deals
         $scope.productRange = data.dealData[0].range
         $scope.deals = _.map $scope.deals, (deal) ->
           products = []
           _.each $scope.productRange, (range) ->
             products.push($scope.findDealProductBudget(deal.deal_products, range) / 100)
           deal.products = products
           return deal

      $scope.init()

      $scope.findDealProductBudget = (dealProducts, productTime) ->
        result =  _.find dealProducts, (dealProduct) ->
          if (dealProduct.start_date == productTime)
            return dealProduct
        if result
          return result.budget
        else
          return 0

      $scope.changeFilter = (filterType) ->
        $scope.filterOpen = filterType

      $scope.isOpen = (deal) ->
        return deal.stage.open == $scope.filterOpen

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.getHtml = (html) ->
        return $sce.trustAsHtml(html)

      $scope.exportReports = ->
        $window.open('/api/deals/pipeline_report.csv')
        return true

  ]
