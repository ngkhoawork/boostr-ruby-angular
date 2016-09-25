@app.controller 'ContactsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$sce', 'Contact', 'Field', 'Activity',  'ActivityType', 'Reminder', '$http'
($scope, $rootScope, $modal, $routeParams, $location, $sce, Contact, Field, Activity, ActivityType, Reminder, $http) ->

  $scope.contacts = []
  $scope.feedName = 'Updates'
  $scope.page = 1
  $scope.query = ""
  $scope.showMeridian = true
  $scope.types = []
  $scope.errors = {}
  $scope.itemType = 'Contact'

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

  $scope.initActivity = (contact, activityTypes) ->
    $scope.activity = {}
    contact.activity = {}
    contact.activeTab = {}
    contact.selected = {}
    contact.populateContact = false
    contact.activeType = activityTypes[0]
    now = new Date
    _.each activityTypes, (type) -> 
      contact.selected[type.name] = {}
      contact.selected[type.name].date = now

    $scope.activityReminderInit()

  $scope.init = ->
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.getContacts()
    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)

  $scope.getContacts = ->
    $scope.isLoading = true
    params = {
      page: $scope.page,
      per: 10
    }
    if $scope.query.trim().length
      params.name = $scope.query.trim()
    Contact.all1(params).then (contacts) ->
      if $scope.page > 1
        $scope.contacts = $scope.contacts.concat(contacts)
      else
        $scope.contacts = contacts
        if contacts.length > 0
          if $scope.currentContact
            Contact.set($scope.currentContact.id || contacts[0].id)
          else
            Contact.set(contacts[0].id)
        else
          $scope.currentContact = null

      _.each $scope.contacts, (contact) ->
        $scope.initActivity(contact, $scope.types)
        $scope.initReminder()
      $scope.isLoading = false

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchContacts = (query) ->
    $scope.page = 1
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getContacts()
      250
    )

  $scope.isLoading = false
  $scope.loadMoreContacts = ->
    if !$scope.isLoading && $scope.contacts && $scope.contacts.length < Contact.totalCount
      $scope.page = $scope.page + 1
      $scope.getContacts()

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}
  $scope.showUploadModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_upload.html'
      size: 'lg'
      controller: 'ContactsUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}

  $scope.showEditModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsEditController'
      backdrop: 'static'
      keyboard: false

  $scope.showActivityEditModal = (activity) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_form.html'
      size: 'lg'
      controller: 'ActivitiesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        activity: ->
          activity
        types: ->
          $scope.types

  $scope.delete = ->
    if confirm('Are you sure you want to delete "' +  $scope.currentContact.name + '"?')
      Contact.delete $scope.currentContact, ->
        $location.path('/people')

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_current_contact')

  $scope.showContact = (contact) ->
    Contact.set(contact.id) if contact
    $scope.initReminder()

  $scope.loadActivities = (contact_id) ->
    Activity.all(contact_id: contact_id).then (activities) ->
      $scope.currentActivities = activities

  $scope.$on 'updated_current_contact', ->
    $scope.currentContact = Contact.get()
    if $scope.currentContact && $scope.currentContact.id
      $scope.loadActivities($scope.currentContact.id)

  $scope.$on 'updated_contacts', ->
    $scope.init()

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.init()

  $scope.submitForm = () ->
    $scope.errors = {}
    $scope.buttonDisabled = true
    if !$scope.currentContact.activity.comment
      $scope.buttonDisabled = false
      $scope.errors['Comment'] = ["can't be blank."]
    if !$scope.currentContact.activity.activeTab
      $scope.buttonDisabled = false
      $scope.errors['Activity Type'] = ["can't be blank."]
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

    if $scope.currentContact.primary_client.client_type_id == $scope.Advertiser
      $scope.activity.client_id = $scope.currentContact.client_id
      $scope.activity.agency_id = null
    else
      $scope.activity.client_id = null
      $scope.activity.agency_id = $scope.currentContact.client_id

    $scope.activity.comment = $scope.currentContact.activity.comment
    $scope.activity.activity_type_id = $scope.currentContact.activeType.id
    $scope.activity.activity_type_name = $scope.currentContact.activeType.name
    contactDate = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].date)
    if $scope.currentContact.selected[$scope.currentContact.activeType.name].time != undefined
      contactTime = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].time)
      contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
      $scope.activity.timed = true
    $scope.activity.happened_at = contactDate
    Activity.create({ activity: $scope.activity, contacts: [$scope.currentContact.id] }, (response) ->
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

  $scope.cancelActivity = (contact) ->
    $scope.initActivity(contact, $scope.types)

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)

#  $scope.reminderModal = ->
#    $scope.modalInstance = $modal.open
#      templateUrl: 'modals/reminder_form.html'
#      size: 'lg'
#      controller: 'ReminderEditController'
#      backdrop: 'static'
#      keyboard: false
#      resolve:
#        itemId: ->
#          $scope.currentContact.id
#        itemType: ->
#          $scope.itemType

  $scope.initReminder = ->
    $scope.showReminder = false;

    if ($scope.currentContact && $scope.currentContact.id)

      $scope.reminder = {
        name: '',
        comment: '',
        completed: false,
        remind_on: '',
        remindable_id: $scope.currentContact.id,
        remindable_type: 'Contact' # "Activity", "Client", "Contact", "Deal"
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
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false

]
