@app.controller 'ContactsController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', 'Contact', 'Activity',  'ActivityType',
($scope, $rootScope, $modal, $routeParams, $location, Contact, Activity, ActivityType) ->

  $scope.showMeridian = true
  $scope.feedName = 'Updates'
  $scope.contacts = []
  $scope.types = []

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
      Contact.all (contacts) ->
        $scope.contacts = contacts
        Contact.set($routeParams.id || contacts[0].id) if contacts.length > 0
        _.each $scope.contacts, (contact) ->
          $scope.initActivity(contact, activityTypes)

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

  $scope.delete = ->
    if confirm('Are you sure you want to delete "' +  $scope.currentContact.name + '"?')
      Contact.delete $scope.currentContact, ->
        $location.path('/people')

  $scope.showContact = (contact) ->
    Contact.set(contact.id) if contact

  $scope.$on 'updated_current_contact', ->
    $scope.currentContact = Contact.get()

  $scope.$on 'updated_contacts', ->
    $scope.init()

  $scope.init()

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    if !$scope.currentContact.activity.activeTab
      $scope.buttonDisabled = false
      return
    $scope.activity.contact_id = $scope.currentContact.id
    $scope.activity.comment = $scope.currentContact.activity.comment
    $scope.activity.activity_type_id = $scope.currentContact.activeType.id
    $scope.activity.activity_type_name = $scope.currentContact.activeType.name
    contactDate = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].date)
    if $scope.currentContact.selected[$scope.currentContact.activeType.name].time != undefined
      contactTime = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].time)
      contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
      $scope.activity.timed = true
    $scope.activity.happened_at = contactDate
    Activity.create({ activity: $scope.activity }, (response) ->
      $scope.buttonDisabled = false
    ).then (activity) ->
      $scope.buttonDisabled = false
      $scope.init()

  $scope.cancelActivity = (contact) ->
    $scope.initActivity(contact, $scope.types)

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)
]
