@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'Client', 'ClientMember', 'Contact', 'Deal', 'Field', 'Activity', 'ActivityType',
($scope, $rootScope, $modal, $routeParams, $location, $window, Client, ClientMember, Contact, Deal, Field, Activity, ActivityType) ->

  $scope.showMeridian = true
  $scope.types = []
  $scope.feedName = 'Updates'
  $scope.clients = []

  $scope.clientFilters = [
    { name: 'My Clients', param: '' }
    { name: 'My Team\'s Clients', param: 'team' }
    { name: 'All Clients', param: 'company' }
  ]

  if $routeParams.filter
    _.each $scope.clientFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.clientFilter = filter
  else
    $scope.clientFilter = $scope.clientFilters[0]

  $scope.init = ->
    $scope.getClients()
    $scope.showContactList = false

  $scope.getClientMembers = ->
    ClientMember.all { client_id: $scope.currentClient.id }, (client_members) ->
      $scope.client_members = client_members
      _.each $scope.client_members, (client_member) ->
        Field.defaults(client_member, 'Client').then (fields) ->
          client_member.role = Field.field(client_member, 'Member Role')

  $scope.getContacts = (client) ->
    unless client.contacts
      Contact.allForClient client.id, (contacts) ->
        client.contacts = contacts

  $scope.getClients = ->
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      Client.all({filter: $scope.clientFilter.param}).then (clients) ->
        $scope.clients = clients
        Client.set($routeParams.id || clients[0].id) if clients.length > 0
        _.each $scope.clients, (client) ->
          $scope.initActivity(client, activityTypes)
 
  $scope.getDeals = (client) ->
    Deal.all({client_id: client.id}).then (deals) ->
      $scope.currentClient.deals = deals

  $scope.showClient = (client) ->
    Client.set(client.id) if client

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'lg'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {}

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

  $scope.showNewDealModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'lg'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: $scope.setupNewDeal

  $scope.setupNewDeal = ->
    deal = {}
    if $scope.currentClient.client_type && $scope.currentClient.client_type.option
      if $scope.currentClient.client_type.option.name == 'Advertiser'
        deal.advertiser_id = $scope.currentClient.id
      else if $scope.currentClient.client_type.option.name == 'Agency'
        deal.agency_id = $scope.currentClient.id
    deal

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

  $scope.updateClientMember = (data) ->
    ClientMember.update(id: data.id, client_id: $scope.currentClient.id, client_member: data)

  $scope.delete = ->
    if confirm('Are you sure you want to delete the client "' +  $scope.currentClient.name + '"?')
      Client.delete $scope.currentClient, ->
        $location.path('/clients')

  $scope.go = (path) ->
    $location.path(path)

  $scope.exportClients = ->
    $window.open('/api/clients.csv')
    return true

  $scope.filterClients = (filter) ->
    $scope.clientFilter = filter
    $scope.init()

  $scope.$on 'updated_current_client', ->
    $scope.currentClient = Client.get()
    if $scope.currentClient
      Field.defaults($scope.currentClient, 'Client').then (fields) ->
        $scope.currentClient.client_type = Field.field($scope.currentClient, 'Client Type')
      $scope.getContacts($scope.currentClient)
      $scope.getDeals($scope.currentClient)
      $scope.getClientMembers()

  $scope.$on 'updated_clients', ->
    $scope.init()

  $scope.$on 'updated_current_contact', ->
    $scope.currentClient.contacts.push(Contact.get())

  $scope.$on 'updated_deals', ->
    $scope.getDeals($scope.currentClient)
    $scope.getClients()

  $scope.$on 'updated_client_members', ->
    $scope.getClientMembers()

  $scope.init()

  $scope.initActivity = (client, types) ->
    $scope.activity = {}
    client.activity = {}
    client.activeTab = {}
    client.selected = {}
    client.activeType = types[0]
    client.populateContact = false
    now = new Date
    _.each types, (type) -> 
      client.selected[type.name] = {}
      client.selected[type.name].date = now

  $scope.setActiveTab = (client, tab) ->
    client.activeTab = tab

  $scope.setActiveType = (client, type) ->
    client.activeType = type

  $scope.searchContact = (name) ->
    Contact.all1({name: name}).then (contacts) ->
      contacts

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    if $scope.currentClient.selected[$scope.currentClient.activeType.name].contact == undefined
      $scope.buttonDisabled = false
      return
    $scope.activity.comment = $scope.currentClient.activity.comment
    $scope.activity.client_id = $scope.currentClient.id
    $scope.activity.activity_type_id = $scope.currentClient.activeType.id
    $scope.activity.activity_type_name = $scope.currentClient.activeType.name
    $scope.activity.contact_id = $scope.currentClient.selected[$scope.currentClient.activeType.name].contact.id
    contactDate = new Date($scope.currentClient.selected[$scope.currentClient.activeType.name].date)
    if $scope.currentClient.selected[$scope.currentClient.activeType.name].time != undefined
      contactTime = new Date($scope.currentClient.selected[$scope.currentClient.activeType.name].time)
      contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
      $scope.activity.timed = true
    $scope.activity.happened_at = contactDate
    Activity.create({ activity: $scope.activity }, (response) ->
      $scope.buttonDisabled = false
    ).then (activity) ->
      $scope.buttonDisabled = false
      $scope.init()

  $scope.createNewContactModal = ->
    $scope.populateContact = true
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}

  $scope.cancelActivity = (client) ->
    $scope.initActivity(client, $scope.types)

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.currentClient.selected[$scope.currentClient.activeType.name].contact = contact
      $scope.populateContact = false

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)
]
