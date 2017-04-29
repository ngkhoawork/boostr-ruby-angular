@app.controller 'AccountController',
['$scope', '$rootScope', '$modal', '$routeParams', '$filter', '$location', '$window', '$sce', 'Client', 'User', 'ClientMember', 'ClientConnection', 'Contact', 'Deal', 'IO', 'AccountCfName', 'Field', 'Activity', 'ActivityType', 'HoldingCompany', 'Reminder', 'BpEstimate', '$http', 'ClientContacts', 'ClientsTypes'
($scope, $rootScope, $modal, $routeParams, $filter, $location, $window, $sce, Client, User, ClientMember, ClientConnection, Contact, Deal, IO, AccountCfName, Field, Activity, ActivityType, HoldingCompany, Reminder, BpEstimate, $http, ClientContacts, ClientsTypes) ->

  $scope.showMeridian = true
  $scope.types = []
  $scope.feedName = 'Updates'
  $scope.clients = []
  $scope.contacts = []
  $scope.query = ""
  $scope.page = 1
  $scope.errors = {}
  $scope.contactSearchText = ""
  $scope.clientContactUrl = 'api/clients/' + $routeParams.id + '/client_contacts/'
  $scope.url = 'api/resources';

  $scope.init = ->
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
    $scope.getClient($routeParams.id)
    $scope.showContactList = false
    getAccountCfNames()
    getHoldingCompanies()
    Contact.query().$promise.then (contacts) ->
      $scope.contacts = contacts
    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

  getAccountCfNames = () ->
    AccountCfName.all().then (accountCfNames) ->
      $scope.accountCfNames = accountCfNames

  $scope.getIconName = (typeName) ->
    typeName && typeName.split(' ').join('-').toLowerCase()

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.getClientMembers = ->
    ClientMember.query({ client_id: $scope.currentClient.id })
      .$promise.then (client_members) ->
        $scope.client_members = []
        client_members.forEach (client_member, index) ->
          Field.defaults(client_member, 'Client').then (fields) ->
            client_member.role = Field.field(client_member, 'Member Role')
            $scope.client_members.push(client_member)

  $scope.getClientStats = ->
    Client.stats({id: $scope.currentClient.id}).$promise.then (data) ->
      $scope.clientStats = data

  $scope.getClientConnections = ->
    ClientConnection.all({client_id: $scope.currentClient.id}).then (client_connections) ->
      $scope.client_connections = client_connections

  $scope.getClientConnectedContacts = ->
    Client.connected_contacts({id: $scope.currentClient.id}).$promise.then (connected_contacts) ->
      $scope.connected_contacts = connected_contacts

  $scope.getChildClients = ->
    Client.child_clients({id: $scope.currentClient.id}).$promise.then (child_clients) ->
      $scope.child_clients = child_clients

  $scope.removeClientMember = (clientMember) ->
    clientMember.$delete(
      null,
      ->
        $scope.client_members = $scope.client_members.filter (cm) ->
          cm.id != undefined
    )

  $scope.setClient = (client) ->
    $scope.currentClient = client
    $scope.activities = client.activities.concat(client.agency_activities)
#    $scope.initActivity()
#    $scope.getContacts()
    $scope.getDeals($scope.currentClient)
    $scope.getClientConnections()
    $scope.initReminder()
    $scope.initRelatedContacts()
    $scope.getClientStats()
    $scope.getBPEstimates()
    $scope.getClients()
    $scope.getClientMembers()

    account_type = Field.field($scope.currentClient, 'Client Type')
    $scope.getIOs(account_type.option.name)
    if account_type.option && account_type.option.name == "Advertiser"
      $scope.getChildClients()
      $scope.getClientConnectedContacts()
    $scope.categoryOptions = Field.findFieldOptions($scope.currentClient.fields, 'Category')
    $scope.segmentOptions = Field.findFieldOptions($scope.currentClient.fields, 'Segment')
    $scope.regionOptions = Field.findFieldOptions($scope.currentClient.fields, 'Region')
    $scope.$emit('updated_current_client')

  $scope.getIOs = (type) ->
    if ($scope.currentClient && $scope.currentClient.id)
      $scope.client_contacts = []
      if type == "Agency"
        IO.all(agency_id: $scope.currentClient.id)
        .then (response) ->
          $scope.ios = response
      else if type == "Advertiser"
        IO.all(advertiser_id: $scope.currentClient.id)
        .then (response) ->
          $scope.ios = response

  $scope.getBPEstimates = () ->
    if ($scope.currentClient && $scope.currentClient.id)
      filters = { bp_id: 0, client_id: $scope.currentClient.id }
      BpEstimate.all(filters).then (response) ->
        $scope.revenues = response.revenues
        $scope.bp_estimates = _.map response.bp_estimates, buildBPEstimate

  buildBPEstimate = (item) ->
    data = angular.copy(item)
    revenue = _.find $scope.revenues, (o) ->
      return o.time_dimension_id == item.time_dimension.id

    data.revenue = 0

    if (revenue)
      data.revenue = revenue.revenue_amount

    return data

  $scope.getContacts = (clientId) ->
    if ($scope.currentClient && $scope.currentClient.id)
      $scope.client_contacts = []
      ClientContacts.list($scope.currentClient.id)
      .then (response) ->
        if (response && response.data && response.data.length)
          $scope.client_contacts = response.data

  $scope.getClient = (clientId) ->
    Client.get({ id: clientId }).$promise.then (client) ->
      $scope.setClient(client)

  $scope.getDeals = (client) ->
    Deal.all({client_id: client.id}).then (deals) ->
      $scope.deals = deals
      $scope.openDealsCount = 0
      $scope.wonDealsCount = 0
      $scope.closedDealsCount = 0
      $scope.interactionsCount = 0
      _.each deals, (deal) ->
        if deal.stage.probability == 100
          $scope.wonDealsCount += 1
        else if deal.stage.probability == 0
          $scope.closedDealsCount += 1
        else
          $scope.openDealsCount += 1

  $scope.getClientCategory = (client) ->
    clientCategory = Field.getOption(client, 'Category', client.client_category_id)
    if clientCategory
      return clientCategory.name
    else
      return ""

  $scope.getLastTouch = (client) ->
    if client
      activities = client.activities
      if $scope.getClientType(client) == 'Agency'
        activities = client.agency_activities
      if activities.length > 0
        return activities[0].happened_at
      else
        return ""
    else
      return ""

  $scope.getActivitiesCount = (client) ->
    if client
      activities = client.activities
      if $scope.getClientType(client) == 'Agency'
        activities = client.agency_activities
      if activities.length > 0
        return activities.length
      else
        return 0
    else
      return 0

  $scope.getClientType = (client) ->
    clientType = Field.field(client, 'Client Type')
    if clientType && clientType.option
      return clientType.option.name
    else
      return ""

  $scope.concatAddress = (address) ->
    row = []
    if address
      if address.city then row.push address.city
      if address.state then row.push address.state
      if address.zip then row.push address.zip
      if address.country then row.push address.country
    row.join(', ')

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.page = 1
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients(query)
      250
    )

  $scope.getClients = (query = '') ->
    $scope.isLoading = true
    params = {
      page: $scope.page
      client_type_id: $scope.currentClient.client_type_id
      filter: "all"
    }
    if query.trim().length
      params.name = query
    Client.query(params).$promise.then (clients) ->
      if $scope.page > 1
        $scope.clients = $scope.clients.concat(clients)
      else
        $scope.clients = clients
      $scope.isLoading = false

  getHoldingCompanies = ->
    HoldingCompany.all({}).then (holdingCompanies) ->
      $scope.holdingCompanies = holdingCompanies

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
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {}

  $scope.showUploadModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_upload.html'
      size: 'lg'
      controller: 'ClientsUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {}

  $scope.deleteAccountConnection = (clientConnection) ->
    return

  $scope.deleteAccountConnectionContact = (connectedContact) ->
    connectedContact.client_id = null
    Contact._update(id: connectedContact.id, contact: connectedContact, unassign: true).then (contact) ->
      $scope.getClientConnectedContacts()


  $scope.showEditModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          $scope.currentClient

  $scope.showAccountEditModal = (client) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          angular.copy(client)

  $scope.showNewActivityModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_new_form.html'
      size: 'md'
      controller: 'ActivityNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        activity: ->
          null
        options: ->
          type: 'account'
          data: $scope.currentClient
          isAdvertiser: $scope.currentClient.client_type_id == $scope.Advertiser

  $scope.showActivityEditModal = (activity) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_new_form.html'
      size: 'md'
      controller: 'ActivityNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        activity: ->
          activity
        options: ->
          type: 'account'
          data: $scope.currentClient
          isAdvertiser: $scope.currentClient.client_type_id == $scope.Advertiser

  $scope.showEmailsModal = (activity) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_emails.html'
      size: 'lg'
      controller: 'ActivityEmailsController'
      backdrop: 'static'
      keyboard: false
      resolve:
        activity: ->
          activity

  $scope.searchContact = (searchText) ->
    if ($scope.contactSearchText != searchText)
      $scope.contactSearchText = searchText
      if $scope.contactSearchText
        Contact.all1(contact_name: $scope.contactSearchText, per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
      else
        Contact.all1(per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
    return searchText
  $scope.showNewPersonModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'md'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          client_id: $scope.currentClient.id

  $scope.showNewDealModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'md'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: $scope.setupNewDeal

  $scope.showNewAccountConnectionContactModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_connection_contact_form.html'
      size: 'md'
      controller: 'AccountConnectionContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          $scope.currentClient
    .result.then (updated_contact) ->
      if updated_contact
        $scope.getClientConnectedContacts()

  $scope.showNewAccountConnectionModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_connection_form.html'
      size: 'md'
      controller: 'AccountConnectionsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        clientConnection: $scope.setupNewClientConnection

  $scope.showEditAccountConnectionModal = (clientConnection) ->
    clientConnectionObj = angular.copy(clientConnection)
    if $scope.currentClient.client_type && $scope.currentClient.client_type.option
      if $scope.currentClient.client_type.option.name == 'Advertiser'
        clientConnectionObj.assignee_type = 'Agency'
      else if $scope.currentClient.client_type.option.name == 'Agency'
        clientConnectionObj.assignee_type = 'Advertiser'
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_connection_form.html'
      size: 'md'
      controller: 'AccountConnectionsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        clientConnection: ->
          clientConnectionObj

  $scope.setupNewClientConnection = ->
    clientConnection = {}
    if $scope.currentClient.client_type && $scope.currentClient.client_type.option
      if $scope.currentClient.client_type.option.name == 'Advertiser'
        clientConnection.advertiser_id = $scope.currentClient.id
        clientConnection.assignee_type = 'Agency'
      else if $scope.currentClient.client_type.option.name == 'Agency'
        clientConnection.agency_id = $scope.currentClient.id
        clientConnection.assignee_type = 'Advertiser'
      clientConnection.primary = false
      clientConnection.active = true
    clientConnection

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

  $scope.showLinkExistingUser = ->
    User.query().$promise.then (users) ->
      $scope.users = $filter('notIn')(users, $scope.currentClient.client_members, 'user_id')

  $scope.linkExistingUser = (item) ->
    $scope.userToLink = undefined
    ClientMember.save(client_id: $scope.currentClient.id, client_member: { user_id: item.id, share: 0, values: [] }).$promise.then (client_member) ->
      $scope.getClientMembers()

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      ClientMember.delete(id: member.id, client_id: $scope.currentClient.id).$promise.then (client) ->
        $scope.getClientMembers()

  $scope.updateClientMember = (data) ->
    ClientMember.update(id: data.id, client_id: $scope.currentClient.id, client_member: data).$promise.then (client) ->
      $scope.getClientMembers()

  $scope.showLinkExistingPerson = ->
    $scope.showContactList = true
    Contact.all (contacts) ->
      $scope.contacts = contacts

  $scope.linkExistingPerson = (item, model) ->
    $scope.contactToLink = undefined
    $scope.showContactList = false
    item.client_id = $scope.currentClient.id
    Contact._update(id: item.id, contact: item).then (contact) ->
      if !$scope.client_contacts
        $scope.client_contacts = []
      $scope.client_contacts.unshift(contact)

#  $scope.updateClientMember = (clientMember) ->
#    clientMember.$update(
#      ->
#        Field.defaults(clientMember, 'Client').then (fields) ->
#          clientMember.role = Field.field(clientMember, 'Member Role')
#    )

  $scope.delete = ->
    if confirm('Are you sure you want to delete the account "' +  $scope.currentClient.name + '"?')
      $scope.currentClient.$delete()
      $location.path('/accounts')

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_activities')

  $scope.deleteAccountConnection = (clientConnection) ->
    if confirm('Are you sure you want to delete the account connection?')
      ClientConnection.delete clientConnection

  $scope.go = (path) ->
    $location.path(path)

  $scope.filterClients = (filter) ->
    $scope.clientFilter = filter
    $scope.init()

  $scope.$on 'updated_current_client', ->
    if $scope.currentClient
      Field.defaults($scope.currentClient, 'Client').then (fields) ->
        $scope.currentClient.client_type = Field.field($scope.currentClient, 'Client Type')
        $scope.currentClient.client_category = Field.getOption($scope.currentClient, 'Category', $scope.currentClient.client_category_id)
        $scope.currentClient.client_subcategory = Field.getSuboption($scope.currentClient, $scope.currentClient.client_category, $scope.currentClient.client_subcategory_id)
        $scope.currentClient.client_region = Field.getOption($scope.currentClient, 'Region', $scope.currentClient.client_region_id)
        $scope.currentClient.client_segment = Field.getOption($scope.currentClient, 'Segment', $scope.currentClient.client_segment_id)


  $scope.$on 'openContactModal', ->
    $scope.createNewContactModal()

  $scope.$on 'updated_clients', ->
    $scope.init()

  $scope.$on 'updated_contacts', ->
    $scope.getContacts()
    $scope.getClientConnectedContacts()

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.$on 'updated_client_connections', ->
    $scope.getClientConnections()
    $scope.getClientConnectedContacts()

  $scope.$on 'updated_current_contact', ->
    $scope.client_contacts.push(Contact.get())

  $scope.$on 'updated_deals', ->
    $scope.getDeals($scope.currentClient)

  $scope.$on 'new_client_member', (_event, args) ->
    Field.defaults(args.clientMember, 'Client').then (fields) ->
      args.clientMember.role = Field.field(args.clientMember, 'Member Role')
      $scope.client_members.push(args.clientMember)

  $scope.$on 'new_client_connection', ->
    $scope.getClientConnections()
    $scope.getClientConnectedContacts()

  $scope.$on 'updated_reminders', ->
    $scope.initReminder()

  $scope.updateClientType = (option) ->
    $scope.currentClient.client_type.option_id = option.id
    $scope.currentClient.$update(
      ->
        $scope.init()
    )

  $scope.updateClientCategory = (category) ->
    $scope.currentClient.client_category_id = category.id
    $scope.currentClient.$update(
      ->
        $scope.$emit('updated_current_client')
    )

  $scope.updateClientSubcategory = (category) ->
    $scope.currentClient.client_subcategory_id = category.id
    $scope.currentClient.$update(
      ->
        $scope.$emit('updated_current_client')
    )

  $scope.updateClientRegion = (region) ->
    $scope.currentClient.client_region_id = region.id
    $scope.currentClient.$update(
      ->
        $scope.$emit('updated_current_client')
    )

  $scope.updateClientSegment = (segment) ->
    $scope.currentClient.client_segment_id = segment.id
    $scope.currentClient.$update(
      ->
        $scope.$emit('updated_current_client')
    )

  $scope.updateClient = ->
    $scope.currentClient.$update(
      ->
        $scope.$emit('updated_current_client')
    )

  $scope.init()

  $scope.activityReminderInit = ->
    $scope.activityReminder = {
      name: '',
      comment: '',
      completed: false,
      remind_on: '',
      remindable_id: 0,
      remindable_type: 'Activity' # "Activity", "Client", "Contact", "Deal"
      _date: new Date(),
      _time: new Date()
    }

    $scope.activityReminderOptions = {
      errors: {},
      showMeridian: true
    }


  $scope.initActivity = () ->
    $scope.activity = new Activity.$resource
    $scope.activity.date = new Date
    $scope.activity.contacts = []
    $scope.activity.activity_type_id = $scope.types[0].id
    $scope.activity.activity_type_name = $scope.types[0].name
    $scope.currentClient.showExtendedActivityForm = false
    $scope.populateContact = false
    $scope.activityReminderInit()

  $scope.setActiveTab = (client, tab) ->
    client.activeTab = tab

  $scope.setActiveType = (client, type) ->
    client.activeType = type

  $scope.submitForm = () ->
    $scope.errors = {}
    $scope.buttonDisabled = true

    if !$scope.activity.comment
      $scope.buttonDisabled = false
      $scope.errors['Comment'] = ["can't be blank."]
    if !($scope.activity && $scope.activity.activity_type_id)
      $scope.buttonDisabled = false
      $scope.errors['Activity Type'] = ["can't be blank."]
    if $scope.activity.contacts.length == 0
      $scope.buttonDisabled = false
      $scope.errors['Contacts'] = ["can't be blank."]
    if $scope.actRemColl
      if !($scope.activityReminder && $scope.activityReminder.name)
        $scope.buttonDisabled = false
        $scope.errors['Activity Reminder Name'] = ["can't be blank."]
      if !($scope.activityReminder && $scope.activityReminder._date)
        $scope.buttonDisabled = false
        $scope.errors['Activity Reminder Date'] = ["can't be blank."]
      if !($scope.activityReminder && $scope.activityReminder._time)
        $scope.buttonDisabled = false
        $scope.errors['Activity Reminder Time'] = ["can't be blank."]
    if !$scope.buttonDisabled
      return

    if $scope.currentClient.client_type_id == $scope.Advertiser
      $scope.activity.client_id = $scope.currentClient.id
      $scope.activity.agency_id = null
    else
      $scope.activity.client_id = null
      $scope.activity.agency_id = $scope.currentClient.id

    contactDate = new Date($scope.activity.date)
    if $scope.activity.time != undefined
      contactTime = new Date($scope.activity.time)
      contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
      $scope.activity.timed = true
    $scope.activity.happened_at = contactDate
    Activity.create({ activity: $scope.activity, contacts: $scope.activity.contacts }, (response) ->
      $scope.buttonDisabled = false
    ).then (activity) ->
      if (activity && activity.id && $scope.actRemColl)
        reminder_date = new Date($scope.activityReminder._date)
        $scope.activityReminder.remindable_id = activity.id
        if $scope.activityReminder._time != undefined
          reminder_time = new Date($scope.activityReminder._time)
          reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
        $scope.activityReminder.remind_on = reminder_date
        Reminder.create(reminder: $scope.activityReminder)
#        .then (reminder) ->
#        , (err) ->

      $scope.buttonDisabled = false
      $scope.init()

  $scope.createNewContactModal = ->
    $scope.populateContact = true

    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'md'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {
            client_id: $scope.currentClient.id,
            primary_client: $scope.currentClient
          }

  $scope.showEditContactModal = (contact) ->
    $scope.populateContact = true
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'md'
      controller: 'ContactsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          angular.copy(contact)

  $scope.cancelActivity = () ->
    $scope.initActivity()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.contacts.push contact
      $scope.populateContact = false

  $scope.$on 'newClient', (event, client) ->
    $scope.getChildClients()
#    $scope.setClient(client)
#    $scope.clients.push(client)

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)

  $scope.initReminder = ->
    $scope.showReminder = false;

    if ($scope.currentClient && $scope.currentClient.id)

      $scope.reminder = {
        name: '',
        comment: '',
        completed: false,
        remind_on: '',
        remindable_id: $scope.currentClient.id,
        remindable_type: 'Client' # "Activity", "Client", "Contact", "Deal"
        _date: new Date(),
        _time: new Date()
      }

      $scope.reminderOptions = {
        editMode: false,
        errors: {},
        buttonDisabled: false,
        showMeridian: true
      }

    #    Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
    $http.get('/api/remindable/'+ $scope.reminder.remindable_id + '/' + $scope.reminder.remindable_type)
    .then (respond) ->
      if (respond && respond.data && respond.data.length)
        _.each respond.data, (reminder) ->
          if (reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
            $scope.reminder.id = reminder.id
            $scope.reminder.name = reminder.name
            $scope.reminder.comment = reminder.comment
            $scope.reminder.completed = reminder.completed
            $scope.reminder._date = new Date(reminder.remind_on)
            $scope.reminder._time = new Date(reminder.remind_on)
            $scope.reminderOptions.editMode = true

  $scope.submitReminderForm = () ->
    $scope.reminderOptions.errors = {}
    $scope.reminderOptions.buttonDisabled = true
    if !($scope.reminder && $scope.reminder.name)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Name'] = "can't be blank."
    if !($scope.reminder && $scope.reminder._date)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Date'] = "can't be blank."
    if !($scope.reminder && $scope.reminder._time)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Time'] = "can't be blank."
    if !$scope.reminderOptions.buttonDisabled
      return

    reminder_date = new Date($scope.reminder._date)
    if $scope.reminder._time != undefined
      reminder_time = new Date($scope.reminder._time)
      reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
    $scope.reminder.remind_on = reminder_date
    if ($scope.reminderOptions.editMode)
      Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
      .then (reminder) ->
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false
    else
      Reminder.create(reminder: $scope.reminder).then (reminder) ->
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
        $scope.reminderOptions.editMode = true
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)

  $scope.initRelatedContacts = () ->
    if ($scope.currentClient && $scope.currentClient.id)
#      if ($scope.currentClient.client_type && $scope.currentClient.client_type.option && $scope.currentClient.client_type.option.name == 'Agency')
#        /api/clients/:client_id/client_contacts
      ClientContacts.related_clients($scope.currentClient.id)
      .then (respond) ->
        if (respond && respond.data && respond.data.length)
          $scope.currentClient.relatedContacts = respond.data

  $scope.showNewChildAccountModal = ->
    if ($scope.currentClient && $scope.currentClient.id)
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/accounts_child_assign_form.html'
        size: 'md'
        controller: 'AccountsChildAssignController'
        backdrop: 'static'
        keyboard: false
        resolve:
          parentClient: ->
            $scope.currentClient
      .result.then (data) ->
        if data
          $scope.getChildClients()

  $scope.showAssignContactModal = (contact) ->
    advertiserTypeId = 0
    ClientsTypes.list().then (clientDefaultTypes) ->
      if clientDefaultTypes && clientDefaultTypes.types && clientDefaultTypes.types.length
        _.each clientDefaultTypes.types, (typeObject) ->
          if typeObject.name == 'Advertiser'
            advertiserTypeId = typeObject.typeId
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/contact_assign_form_copy_for_clients.html'
        size: 'md'
        controller: 'ContactsAssignController'
        backdrop: 'static'
        keyboard: false
        resolve:
          contact: ->
            contact
          typeId: ->
            advertiserTypeId
      .result.then (updated_contact) ->
        $scope.initRelatedContacts()
        $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
          if (item.id == updated_contact.id)
            return updated_contact
          else
            return item
        $scope.contactNotification[updated_contact.id] = "Assigned to " + updated_contact.clients[0].name
        $scope.contactActionLog.push({
          previousContact: contact,
          message: updated_contact.clients[0].name
        })
]
