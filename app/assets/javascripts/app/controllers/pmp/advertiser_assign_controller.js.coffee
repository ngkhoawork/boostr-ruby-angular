@app.controller 'AdvertiserAssignController',
  ['$scope', '$modalInstance', 'pmpItemDailyActual', 'Client', 'PMPItemDailyActual', 
  ( $scope,   $modalInstance,   pmpItemDailyActual,   Client,   PMPItemDailyActual) ->
    $scope.submitText = 'Create New'
    $scope.searchText = pmpItemDailyActual.advertiser
    $scope.clients = []
    selectedClient = null

    init = () ->
      $scope.searchObj()

    $scope.searchObj = () ->
      selectedClient = null
      $scope.submitText = 'Create New'
      Client.fuzzy_search(search: $scope.searchText).$promise.then (clients) ->
        $scope.clients = clients

    $scope.assign = (client) ->
      selectedClient = client
      $scope.submitText = 'Save'
      $scope.searchText = client.name

    $scope.submit = () ->
      PMPItemDailyActual.assignAdvertiser(id: pmpItemDailyActual.id, name: $scope.searchText).then () ->
        $modalInstance.close()

    $scope.cancel = ->
      $modalInstance.dismiss()

    init()
  ]
