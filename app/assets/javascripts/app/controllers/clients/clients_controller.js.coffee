@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', 'Client', 'Contact', 'ClientMember',
($scope, $rootScope, $modal, $routeParams, $location, Client, Contact, ClientMember) ->

  $scope.init = ->
    Client.all().then (clients) ->
      $scope.clients = clients
      Client.set($routeParams.id || clients[0].id)
    $scope.showContactList = false

  $scope.getClientMembers = ->
    ClientMember.all { client_id: $scope.currentClient.id }, (client_members) ->
      $scope.client_members = client_members

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

  $scope.showNewPersonModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          client_id: $scope.currentClient.id

  $scope.showNewMemberModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/member_form.html'
      size: 'lg'
      controller: 'ClientMembersNewController'
      backdrop: 'static'
      keyboard: false

  $scope.showLinkExistingPerson = ->
    $scope.showContactList = true
    Contact.all (contacts) ->
      $scope.contacts = contacts

  $scope.linkExistingPerson = (item, model) ->
    $scope.contactToLink = undefined
    $scope.showContactList = false
    item.client_id = $scope.currentClient.id
    Contact.update(id: item.id, contact: item).then (contact) ->
      $scope.currentClient.contacts.push(contact)

  $scope.delete = ->
    if confirm('Are you sure you want to delete the client "' +  $scope.currentClient.name + '"?')
      Client.delete $scope.currentClient, ->
        $location.path('/clients')

  $scope.go = (path) ->
    $location.path(path)

  $scope.$on 'updated_current_client', ->
    $scope.currentClient = Client.get()
    $scope.getContacts($scope.currentClient)
    $scope.getClientMembers()

  $scope.$on 'updated_clients', ->
    $scope.init()

  $scope.$on 'updated_current_contact', ->
    $scope.currentClient.contacts.push(Contact.get())

  $scope.$on 'updated_client_members', ->
    $scope.getClientMembers()


  $scope.init()
]
