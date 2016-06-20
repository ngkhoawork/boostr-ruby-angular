@app.controller 'ClientsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'Client', 'ClientMember', 'Contact', 'Deal', 'Field', 'Activity', 'ActivityType',
($scope, $rootScope, $modal, $routeParams, $location, $window, Client, ClientMember, Contact, Deal, Field, Activity, ActivityType) ->

  $scope.showMeridian = true
  $scope.types = []
  $scope.feedName = 'Updates'
  $scope.clients = []
  $scope.contacts = []
  $scope.query = ""
  $scope.page = 1

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
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
    $scope.getClient($routeParams.id) if $routeParams.id
    $scope.getClients()
    $scope.showContactList = false

  $scope.getClientMembers = ->
    ClientMember.query({ client_id: $scope.currentClient.id })
      .$promise.then (client_members) ->
        $scope.client_members = []
        client_members.forEach (client_member, index) ->
          Field.defaults(client_member, 'Client').then (fields) ->
            client_member.role = Field.field(client_member, 'Member Role')
            $scope.client_members.push(client_member)

  $scope.getContacts = (client) ->
    unless client.contacts
      Contact.allForClient client.id, (contacts) ->
        $scope.contacts = contacts
        client.contacts = contacts

  $scope.removeClientMember = (clientMember) ->
    clientMember.$delete(
      null,
      ->
        $scope.client_members = $scope.client_members.filter (cm) ->
          cm.id != undefined
    )

  $scope.setClient = (client) ->
    $scope.currentClient = client
    $scope.initActivity()
    $scope.getContacts($scope.currentClient)
    $scope.getDeals($scope.currentClient)
    $scope.getClientMembers()

  $scope.getClient = (clientId) ->
    Client.get({ id: clientId }).$promise.then (client) ->
      $scope.setClient(client)

  $scope.getClients = ->
    $scope.isLoading = true
    params = {
      filter: $scope.clientFilter.param,
      page: $scope.page
    }
    if $scope.query.trim().length
      params.name = $scope.query.trim()
    Client.query(params).$promise.then (clients) ->
      if $scope.page > 1
        $scope.clients = $scope.clients.concat(clients)
      else
        $scope.clients = clients
        if clients.length > 0 and !$routeParams.id
          $scope.setClient(clients[0])
      $scope.isLoading = false

  $scope.getDeals = (client) ->
    Deal.all({client_id: client.id}).then (deals) ->
      $scope.currentClient.deals = deals

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.page = 1
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients()
      250
    )

  $scope.isLoading = false
  $scope.loadMoreClients = ->
    if !$scope.isLoading && $scope.clients && $scope.clients.length < Client.totalCount
      $scope.page = $scope.page + 1
      $scope.getClients()

  $scope.showClient = (client) ->
    if client
      $scope.setClient(client)

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
      resolve:
        client: ->
          $scope.currentClient

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
      resolve:
        client: ->
          $scope.currentClient

  $scope.showLinkExistingPerson = ->
    $scope.showContactList = true
    Contact.all (contacts) ->
      $scope.contacts = contacts

  $scope.linkExistingPerson = (item, model) ->
    $scope.contactToLink = undefined
    $scope.showContactList = false
    item.client_id = $scope.currentClient.id
    Contact.update(id: item.id, contact: item).then (contact) ->
      if !$scope.currentClient.contacts
        $scope.currentClient.contacts = []
      $scope.currentClient.contacts.unshift(contact)

  $scope.updateClientMember = (clientMember) ->
    clientMember.$update(
      ->
        Field.defaults(clientMember, 'Client').then (fields) ->
          clientMember.role = Field.field(clientMember, 'Member Role')
    )

  $scope.delete = ->
    if confirm('Are you sure you want to delete the client "' +  $scope.currentClient.name + '"?')
      $scope.clients = $scope.clients.filter (el) ->
        el.id != $scope.currentClient.id
      $scope.currentClient.$delete()
      if $scope.clients.length
        $scope.setClient $scope.clients[0]
      else
        $scope.currentClient = null
      $scope.$emit('updated_current_client')
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

  $scope.$on 'new_client_member', (_event, args) ->
    Field.defaults(args.clientMember, 'Client').then (fields) ->
      args.clientMember.role = Field.field(args.clientMember, 'Member Role')
      $scope.client_members.push(args.clientMember)

  $scope.init()

  $scope.initActivity = () ->
    $scope.activity = new Activity.$resource
    $scope.activity.date = new Date
    $scope.activity.contacts = []
    $scope.showExtendedActivityForm = false
    $scope.populateContact = false

  $scope.setActiveTab = (client, tab) ->
    client.activeTab = tab

  $scope.setActiveType = (client, type) ->
    client.activeType = type

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    if $scope.activity.contacts.length == 0
      $scope.buttonDisabled = false
      return
    $scope.activity.client_id = $scope.currentClient.id
    contactDate = new Date($scope.activity.date)
    if $scope.activity.time != undefined
      contactTime = new Date($scope.activity.time)
      contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
      $scope.activity.timed = true
    $scope.activity.happened_at = contactDate
    Activity.create({ activity: $scope.activity, contacts: $scope.activity.contacts }, (response) ->
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
    $scope.initActivity()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.currentClient.selected[$scope.currentClient.activeType.name].contacts.push contact
      $scope.populateContact = false

  $scope.$on 'newClient', (event, client) ->
    $scope.setClient(client)
    $scope.clients.push(client)

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)
]
