@app.controller 'AdvertiserAssignController',
  ['$scope', '$modalInstance', 'pmpItemDailyActual', 'Client', 'PMPItemDailyActual', '$modal',
  ( $scope,   $modalInstance,   pmpItemDailyActual,   Client,   PMPItemDailyActual,   $modal) ->
    $scope.searchText = pmpItemDailyActual.ssp_advertiser
    $scope.clients = []

    init = () ->
      $scope.searchObj()

    $scope.searchObj = () ->
      Client.fuzzy_search(search: $scope.searchText).$promise.then (clients) ->
        $scope.clients = clients

    $scope.assign = (client) ->
      PMPItemDailyActual.assignAdvertiser(id: pmpItemDailyActual.id, client_id: client.id).then () ->
        $modalInstance.close()

    $scope.create = () ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/client_form.html'
        size: 'md'
        controller: 'AccountsNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          client: ->
            {}
      .result.then (client) ->
        if client
          $scope.assign(client)

    $scope.cancel = ->
      $modalInstance.dismiss()

    init()
  ]
