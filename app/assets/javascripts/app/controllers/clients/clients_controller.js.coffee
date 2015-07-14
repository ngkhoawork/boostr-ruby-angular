@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', '$routeParams', 'Client',
($scope, $rootScope, $modal, $routeParams, Client) ->

  $scope.init = ->
    Client.all (clients) ->
      $scope.clients = clients
      Client.set($routeParams.id || clients[0].id)

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/new_client.html'
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_current_client', ->
    $scope.currentClient = Client.get()

  $scope.$on 'updated_clients', ->
    $scope.init()

  $scope.init()
]
