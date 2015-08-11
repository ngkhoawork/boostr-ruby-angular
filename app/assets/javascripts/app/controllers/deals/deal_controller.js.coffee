@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', 'Deal', 'Product', 'DealProduct',
($scope, $routeParams, $modal, $filter, Deal, Product, DealProduct) ->

  $scope.init = ->
    $scope.currentDeal = {}
    $scope.resetDealProduct()

    Deal.get($routeParams.id).then (deal) ->
      $scope.currentDeal = deal

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.months.push({ value: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all().then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

  $scope.$watch 'deal_product.total_budget', ->
    budget = $scope.deal_product.total_budget / $scope.deal_product.months.length
    for month in $scope.deal_product.months
      month.value = $filter('currency')(budget, '$', 0)

  $scope.addProduct = ->
    DealProduct.create($scope.deal_product).then (deal) ->
      $scope.showProductForm = false
      $scope.currentDeal = deal

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      deal_id: $routeParams.id
      months: []
    }

  $scope.init()
]
