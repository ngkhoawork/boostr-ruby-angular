@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', '$location', '$anchorScroll', 'Deal', 'Product', 'DealProduct', 'DealMember', 'Stage', 'User', 'Field',
($scope, $routeParams, $modal, $filter, $location, $anchorScroll, Deal, Product, DealProduct, DealMember, Stage, User, Field) ->

  $scope.init = ->
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal)

    $scope.anchors = [{name: 'campaign', id: 'campaign'},
                      {name: 'team & split', id: 'teamsplit'},
                      {name: 'documents', id: 'documents'},
                      {name: 'additional info', id: 'info'}]

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal

  $scope.getStages = ->
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
    DealMember.create(deal_id: $scope.currentDeal.id, deal_member: { user_id: item.id, share: 0, values: [] }).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDeal = ->
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealStage = (currentDeal) ->
    if currentDeal != null
      Stage.get(currentDeal.stage_id).then (stage) ->
        if !stage.open
          $scope.showModal(currentDeal)
        else
          Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
            if currentDeal.close_reason.option == undefined
              $scope.setCurrentDeal(deal)
            else
              $scope.init()

  $scope.updateDealProduct = (data) ->
    DealProduct.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealMember = (data) ->
    DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      DealMember.delete(id: member.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.deleteProduct = (product) ->
    if confirm('Are you sure you want to delete "' +  product.name + '"?')
      DealProduct.delete(id: product.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.isActive = (id) ->
    $scope.activeAnchor == id

  $scope.scrollTo = (id) ->
    $scope.activeAnchor = id
    $anchorScroll(id)

  $scope.cancelAddProduct = ->
    $scope.showProductForm = !$scope.showProductForm

  $scope.showModal = (currentDeal) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_close_form.html'
      size: 'lg'
      controller: 'DealsCloseController'
      backdrop: 'static'
      keyboard: false
      resolve:
        currentDeal: ->
          currentDeal

  $scope.$on 'updated_deal', ->
    $scope.init()

  $scope.init()
]
