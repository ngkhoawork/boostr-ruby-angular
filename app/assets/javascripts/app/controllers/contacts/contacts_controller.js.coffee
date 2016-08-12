@app.controller 'ContactsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', 'Contact', 'Activity',  'ActivityType', 'Reminder'
($scope, $rootScope, $modal, $routeParams, $location, Contact, Activity, ActivityType, Reminder) ->

  $scope.contacts = []
  $scope.feedName = 'Updates'
  $scope.page = 1
  $scope.query = ""
  $scope.showMeridian = true
  $scope.types = []
  $scope.errors = {}
  $scope.itemType = 'Contact'

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

  $scope.init = ->
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.getContacts()


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
        contacts: ->
          $scope.contacts
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

  $scope.$on 'updated_current_contact', ->
    $scope.currentContact = Contact.get()

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
    if !$scope.buttonDisabled
      return
    $scope.activity.client_id = $scope.currentContact.client_id
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

      Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
        console.log('Reminder', reminder)
        if (reminder && reminder.id)
          $scope.reminder.id = reminder.id
          $scope.reminder.name = reminder.name
          $scope.reminder.comment = reminder.comment
          $scope.reminder._date = new Date(reminder.remind_on)
          $scope.reminder._time = new Date(reminder.remind_on)
          $scope.reminderOptions.editMode = true

  $scope.submitReminderForm = () ->
    console.log('I am a reminder submit')
    $scope.reminderOptions.errors = {}
    $scope.reminderOptions.buttonDisabled = true
    reminder_date = new Date($scope.reminder._date)
    if $scope.reminder._time != undefined
      reminder_time = new Date($scope.reminder._time)
      reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
    $scope.reminder.remind_on = reminder_date
    if ($scope.reminderOptions.editMode)
      Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
      .then (reminder) ->
        console.log('Reminder update', reminder)
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
      , (err) ->
        console.log('err', err)
        $scope.reminderOptions.buttonDisabled = false
    else
      Reminder.create(reminder: $scope.reminder).then (reminder) ->
        console.log('Reminder create', reminder)
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
      , (err) ->
        console.log('err', err)
        $scope.reminderOptions.buttonDisabled = false

]
