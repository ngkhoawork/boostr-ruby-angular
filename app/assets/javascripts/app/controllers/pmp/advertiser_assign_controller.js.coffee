@app.controller 'AdvertiserAssignController',
  ['$scope', '$modalInstance', 'pmpItemDailyActual', 'Client', 'PMPItemDailyActual', '$modal',
  ( $scope,   $modalInstance,   pmpItemDailyActual,   Client,   PMPItemDailyActual,   $modal) ->
    $scope.searchText = pmpItemDailyActual.ssp_advertiser
    $scope.pmpItemDailyActual = pmpItemDailyActual
    $scope.clients = []
    $scope.bulkUpdate = false

    init = () ->
      $scope.searchObj()

    $scope.searchObj = () ->
      Client.fuzzy_search(search: $scope.searchText).$promise.then (clients) ->
        $scope.clients = clients

    $scope.assign = (client) ->
      if $scope.bulkUpdate
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/advertiser_assign_warning.html'
          size: 'md'
          controller: 'AdvertiserAssignWarningController'
          backdrop: 'static'
          keyboard: false
          resolve:
            message: -> "This action will assign advertiser - \"#{client.name}\" to all no-matching records which have same SSP advertiser - \"#{pmpItemDailyActual.ssp_advertiser}\". Are you sure about this?"
        .result.then () ->
          PMPItemDailyActual.bulkAssignAdvertiser(ssp_advertiser: pmpItemDailyActual.ssp_advertiser, client_id: client.id).then (result) ->
            $modalInstance.close(result)
      else
        PMPItemDailyActual.assignAdvertiser(id: pmpItemDailyActual.id, client_id: client.id).then (result) ->
          $modalInstance.close([result.id])

    $scope.create = () ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/client_form.html'
        size: 'md'
        controller: 'AccountsNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          client: -> {}
          options: -> {}
      .result.then (client) ->
        if client
          $scope.assign(client)

    $scope.cancel = ->
      $modalInstance.dismiss()

    init()
  ]
