@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', 'Client',
($scope, $rootScope, $modal, Client) ->

  $scope.init = ->
    Client.all (clients) ->
      $scope.clients = clients
      $scope.currentClient = Client.get()

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_client.html'
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false

  $rootScope.$on 'updated_clients', ->
    $scope.init()

  $scope.init()
]
