@app.controller "AgreementsAssignController",
['$scope', '$modal', '$modalInstance', 'Agreement', 'deal'
($scope, $modal, $modalInstance, Agreement, deal) ->
  $scope.showAgreementsDropdown = false
  agreementsClone = []
  excludeAgreements = []

  $scope.init = ->
    getAgreements()
    $scope.assignedAgreements = []

  getAgreements = (search = '') ->
    Agreement.get_available_agreements id: deal.id, (agreements) ->
      $scope.agreements = agreements
      agreementsClone = agreements
      filterAgreements()

  filterAgreements = (excludeAgrements) ->
    dealAgreements = deal.agreements.map (agreement) -> id: agreement.id
    excludeAgreements = _.uniq($scope.assignedAgreements.concat dealAgreements, 'id')
    $scope.agreements = _.filter agreementsClone, (agreement) ->
      !_.findWhere(excludeAgreements, { id: agreement.id })

  $scope.selectAgreement = (agreement) ->
    isAssigned = false
    $scope.assignedAgreements.forEach(
      (assignedAagreement, index) ->
        if agreement.id == assignedAagreement.id
          isAssigned = true
    )
    unless isAssigned
      $scope.assignedAgreements.push(agreement)
      filterAgreements(excludeAgreements)

  $scope.removeAgreement = (agreement) ->
    $scope.assignedAgreements.forEach(
      (assignedAagreement, index) ->
        if agreement.id == assignedAagreement.id
          $scope.assignedAgreements.splice(index, 1)
    )
    filterAgreements(excludeAgreements)

  $scope.onModalClick = (event) ->
    target = angular.element(event.target)
    if target[0].className.includes("form-control-wrapper") || target.parents(".form-control-wrapper").length || target[0].className.includes('select')
      $scope.showAgreementsDropdown = true
    else
      $scope.showAgreementsDropdown = false

  $scope.searchObj = (search = '') -> getAgreements(search)

  $scope.showAddAgreementModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/agreements_add.html'
      size: 'md'
      controller: 'AgreementsAddController'
      backdrop: 'static'
      keyboard: false
      resolve:
        options: -> deal: deal

    .result.then (newAgreement) -> 
      if !newAgreement.manually_tracked
        newAgreement.assigned = true
      $scope.assignedAgreements.unshift(newAgreement) 

  $scope.assignAgreements = ->
    $scope.assignedAgreements = $scope.assignedAgreements.filter (agreement) -> !agreement.assigned
    agreementIds = $scope.assignedAgreements.map((agreement) -> agreement.id)
    if $scope.assignedAgreements.length
      Agreement.assign_agreements( deal_id: deal.id, { assign_agreements: agreementIds },
        (data) -> $modalInstance.close($scope.assignedAgreements)
        (reject) -> console.error reject
      )
    else
      $modalInstance.close()

  $scope.cancel = -> $modalInstance.close()

  $scope.init()

]
