@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', 'Deal', 'Product', 'DealProduct', 'DealMember', 'Stage', 'User',
($scope, $routeParams, $modal, $filter, Deal, Product, DealProduct, DealMember, Stage, User) ->

  $scope.init = ->
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    $scope.dealTypes = Deal.deal_types()
    $scope.sourceTypes = Deal.source_types()
    $scope.memberRoles = DealMember.roles()
    $scope.memberAccess = DealMember.access()
    Deal.get($routeParams.id).then (deal) ->
      $scope.currentDeal = deal
    Stage.all().then (stages) ->
      $scope.stages = stages

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.months.push({ value: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all().then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

  $scope.$watch 'deal_product.total_budget', ->
    budget = $scope.deal_product.total_budget / $scope.currentDeal.days
    _.each $scope.deal_product.months, (month, index) ->
      month.value = $filter('currency')($scope.currentDeal.days_per_month[index] * budget, '$', 0)

  $scope.addProduct = ->
    DealProduct.create($scope.deal_product).then (deal) ->
      $scope.showProductForm = false
      $scope.currentDeal = deal

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      deal_id: $routeParams.id
      months: []
    }

  $scope.showLinkExistingUser = ->
    User.all().then (users) ->
      $scope.users = $filter('notIn')(users, $scope.currentDeal.members, 'user_id')

  $scope.linkExistingUser = (item) ->
    $scope.userToLink = undefined
    DealMember.create(deal_id: $scope.currentDeal.id, user_id: item.id, share: 0).then (deal) ->
      $scope.currentDeal = deal

  $scope.updateDeal = ->
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
      $scope.currentDeal = deal

  $scope.updateDealProduct = (data) ->
    DealProduct.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product: data).then (deal) ->
      $scope.currentDeal = deal

  $scope.updateDealMember = (data) ->
    DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
      $scope.currentDeal = deal

  $scope.init()
]
