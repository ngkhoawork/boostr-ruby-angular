@app.controller "AgreementAssignDealsController",
['$scope', '$modal', '$modalInstance', 'Agreement', 'agreement', 'HoldingCompany'
($scope, $modal, $modalInstance, Agreement, agreement, HoldingCompany) ->
  $scope.showDealsDropdown = false
  $scope.loaded = false
  $scope.canAssign = true
  dealsClone = []

  init = ->
    getAvailableDeals()
    $scope.assignedDeals = []
    if agreement && !agreement.agencies.length && agreement.holding_company
      $scope.canAssign = false
      HoldingCompany.relatedAccounts(agreement.holding_company.id)
        .then (relatedAccounts) ->
          $scope.loaded = true
          if relatedAccounts && relatedAccounts.length  
            $scope.canAssign = true

  getAvailableDeals = ->
    Agreement.get_available_deals({ spend_agreement_id: agreement.id }
      (available_deals) ->
        $scope.deals = available_deals
        dealsClone = available_deals
    )

  $scope.selectDeal = (deal) ->
    isAssigned = false
    $scope.assignedDeals.forEach(
      (assignedDeal, index) ->
        if deal.id == assignedDeal.id
          isAssigned = true
    )
    unless isAssigned
      $scope.assignedDeals.unshift(deal)
      $scope.deals = _.filter(dealsClone,
        (deal) ->
          !_.findWhere($scope.assignedDeals, deal)
      )

  $scope.removeDeal = (deal) ->
    $scope.assignedDeals.forEach(
      (assignedDeal, index) ->
        if deal.id == assignedDeal.id
          $scope.assignedDeals.splice(index, 1)
    )
    $scope.deals = _.filter(dealsClone,
      (deal) ->
        !_.findWhere($scope.assignedDeals, deal)
    )

  $scope.onModalClick = (event) ->
    target = angular.element(event.target)
    if target[0].className.includes("form-control-wrapper") || target.parents(".form-control-wrapper").length || target[0].className.includes('select')
      $scope.showDealsDropdown = true
    else
      $scope.showDealsDropdown = false

  $scope.showAddDealModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'md'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: -> {}
        options: -> agreement: agreement
    .result.then (deal) -> $scope.assignedDeals.unshift(deal) if deal

  $scope.assignDeals = ->
    dealIds = $scope.assignedDeals.map((deal) -> deal_id: deal.id)
    $modalInstance.close(dealIds)

  $scope.cancel = -> $modalInstance.close()

  init()
  
]
