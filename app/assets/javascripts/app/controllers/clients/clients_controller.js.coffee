@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', 'Client', 'Contact',
($scope, $rootScope, $modal, $routeParams, $location, Client, Contact) ->

  $scope.init = ->
    Client.all (clients) ->
      $scope.clients = clients
      Client.set($routeParams.id || clients[0].id)

  $scope.getContacts = (client) ->
    unless client.contacts
      Contact.allForClient client.id, (contacts) ->
        client.contacts = contacts

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false

  $scope.showEditModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'lg'
      controller: 'ClientsEditController'
      backdrop: 'static'
      keyboard: false

  $scope.delete = ->
    if confirm('Are you sure you want to delete the client "' +  $scope.currentClient.name + '"?')
      Client.delete $scope.currentClient, ->
        $location.path('/clients')

  $scope.go = (path) ->
    $location.path(path)

  $scope.$on 'updated_current_client', ->
    $scope.currentClient = Client.get()
    $scope.getContacts($scope.currentClient)

  $scope.$on 'updated_clients', ->
    $scope.init()

  $scope.init()
]
