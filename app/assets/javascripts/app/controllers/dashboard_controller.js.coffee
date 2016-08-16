@app.controller 'DashboardController',
['$scope', '$http', '$modal', 'Dashboard', 'Deal', 'Client', 'Contact', 'Activity', 'ActivityType', 'Reminder',
($scope, $http, $modal, Dashboard, Deal, Client, Contact, Activity, ActivityType, Reminder) ->

  $scope.showMeridian = true
  $scope.feedName = 'Activity Updates'
  $scope.moreSize = 10;
  $scope.types = []

  $scope.init = ->
    $scope.currentPage = 0;
    $scope.activity = {}
    $scope.activeTab = {}
    $scope.selectedObj = {}
    $scope.selectedObj.deal = true
    $scope.selected = {}
    $scope.populateContact = false
    $scope.contacts = []
    $scope.errors = {}

    $scope.actRemColl = false;

    $scope.reminder = {
      name: '',
      comment: '',
      completed: false,
      remind_on: '',
      remindable_id: 0,
      remindable_type: 'Activity' # "Activity", "Client", "Contact", "Deal"
      _date: new Date(),
      _time: new Date()
    }

    $scope.reminderOptions = {
      errors: {},
      showMeridian: true
    }

    now = new Date
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.activeType = activityTypes[0]
      _.each activityTypes, (type) ->
        $scope.selected[type.name] = {}
        $scope.selected[type.name].date = now
        $scope.selected[type.name].contacts = []

    $scope.activity_objects = {}
    Activity.all().then (activities) ->
      activities.forEach (activity) ->
        objectIds = []

        if activity.deal
          objectId = "d:" + activity.deal.id
          if not $scope.activity_objects.hasOwnProperty(objectId)
            $scope.activity_objects[objectId] = activity.deal
            $scope.activity_objects[objectId].isDeal = true
            $scope.activity_objects[objectId].activities = []
          objectIds.push(objectId)

        if activity.client
          objectId = "c:" + activity.client.id
          if not $scope.activity_objects.hasOwnProperty(objectId)
            $scope.activity_objects[objectId] = activity.client
            $scope.activity_objects[objectId].activities = []
            $scope.activity_objects[objectId].isClient = true
          objectIds.push(objectId)

        objectIds.forEach (objectId) ->
          $scope.activity_objects[objectId].activities.push(activity)

    Contact.$resource.query().$promise.then (contacts) ->
      $scope.contacts = contacts

  $scope.chartOptions = {
    responsive: false,
    segmentShowStroke: true,
    segmentStrokeColor: '#fff',
    segmentStrokeWidth: 2,
    percentageInnerCutout: 70,
    animationSteps: 100,
    animationEasing: 'easeOutBounce',
    animateRotate: true,
    animateScale: false,
    showTooltips: false
  }

  Dashboard.get().then (dashboard) ->
    $scope.dashboard = dashboard
    $scope.forecast = dashboard.forecast
    $scope.setChartData()

  $scope.showNewDealModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'lg'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          {}

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

  $scope.setChartData = () ->
    $scope.chartData = [
      {
        value: Math.min($scope.forecast.percent_to_quota, 100),
        color:'#FB6C22',
        highlight: '#FB6C22',
        label: 'Complete'
      },
      {
        value: Math.max(100 - $scope.forecast.percent_to_quota, 0),
        color: '#FEA673',
        highlight: '#FEA673',
        label: 'Remaining'
      }
    ]

  $scope.$on 'updated_dashboards', ->
    $scope.init()

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.init()

  $scope.setActiveTab = (tab) ->
    $scope.activeTab = tab

  $scope.setActiveType = (type) ->
    $scope.activeType = type

  $scope.searchObj = (name) ->
    if $scope.selectedObj.deal
      Deal.all({name: name}).then (deals) ->
        deals
    else
      Client.query({name: name}).$promise.then (clients) ->
        clients

  $scope.submitForm = (form) ->
    $scope.errors = {}
    $scope.buttonDisabled = true

    if form.$valid
      if !$scope.activity.comment
        $scope.buttonDisabled = false
        $scope.errors['Comment'] = ["can't be blank."]
      if $scope.selectedObj.obj != undefined
        if $scope.selectedObj.deal
          $scope.activity.deal_id = $scope.selectedObj.obj.id
          $scope.activity.client_id = $scope.selectedObj.obj.advertiser_id
        else
          $scope.activity.client_id = $scope.selectedObj.obj.id
      else
        $scope.buttonDisabled = false
        $scope.errors['Deal or Client'] = ["should be present."]
      if !($scope.activeType && $scope.activeType.id)
        $scope.buttonDisabled = false
        $scope.errors['Activity Type'] = ["can't be blank."]
      if $scope.selected[$scope.activeType.name].contacts.length == 0
        $scope.buttonDisabled = false
        $scope.errors['Contacts'] = ["can't be blank."]
      if $scope.actRemColl
        if !($scope.reminder && $scope.reminder.name)
          $scope.buttonDisabled = false
          $scope.errors['Reminder Name'] = ["can't be blank."]
        if !($scope.reminder && $scope.reminder._date)
          $scope.buttonDisabled = false
          $scope.errors['Reminder Date'] = ["can't be blank."]
        if !($scope.reminder && $scope.reminder._time)
          $scope.buttonDisabled = false
          $scope.errors['Reminder Time'] = ["can't be blank."]
      if !$scope.buttonDisabled
        return

      form.submitted = true
      $scope.activity.activity_type_id = $scope.activeType.id
      $scope.activity.activity_type_name = $scope.activeType.name
      contact_date = new Date($scope.selected[$scope.activeType.name].date)
      if $scope.selected[$scope.activeType.name].time != undefined
        contact_time = new Date($scope.selected[$scope.activeType.name].time)
        contact_date.setHours(contact_time.getHours(), contact_time.getMinutes(), 0, 0)
        $scope.activity.timed = true
      $scope.activity.happened_at = contact_date
      console.log($scope.actRemColl)
      Activity.create({ activity: $scope.activity, contacts: $scope.selected[$scope.activeType.name].contacts }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (activity) ->
        console.log('activity', activity)
        console.log('activity.id', activity.id)
        console.log($scope.actRemColl)
        if (activity && activity.id && $scope.actRemColl)
          console.log('reminder should be created')
          reminder_date = new Date($scope.reminder._date)
          $scope.reminder.remindable_id = activity.id
          if $scope.reminder._time != undefined
            reminder_time = new Date($scope.reminder._time)
            reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
          $scope.reminder.remind_on = reminder_date
          Reminder.create(reminder: $scope.reminder).then (reminder) ->
            $scope.reminder = reminder
            $scope.reminder._date = new Date($scope.reminder.remind_on)
            $scope.reminder._time = new Date($scope.reminder.remind_on)
          , (err) ->

        $scope.buttonDisabled = false
        $scope.init()
        $scope.remindersInit()

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

  $scope.cancelActivity = ->
    $scope.init()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.contacts.push(contact)
      $scope.selected[$scope.activeType.name].contacts.push(contact.id)
      $scope.populateContact = false

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_activities')

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)

  $scope.remindersInit = ->
    $scope.remindersOptions = {
      errors: {},
      showMeridian: true,
      editMode: false,
      buttonDisabled: false
    }

    $scope.reminders = []
    $scope.completedReminders = []
    $http.get('/api/reminders')
    .then (respond) ->
      if (respond && respond.data && respond.data.length)
        _.each respond.data, (curReminder) ->
#                    curReminder.editMode = false
#                    curReminder.collapsed = true
          curReminder._date = new Date(curReminder.remind_on)
          curReminder._time = new Date(curReminder.remind_on)
          now = new Date();
          timeDiff = curReminder._date.getTime() - now.getTime();
          diffDays = timeDiff / (1000 * 3600 * 24);
          if (diffDays <= 1 )
            curReminder.dateColorClass = 'red';
          if (diffDays > 1  && diffDays < 2)
            curReminder.dateColorClass = 'yellow';
          if (diffDays >= 2 )
            curReminder.dateColorClass = 'silver';
          curReminder.completed = !!curReminder.completed
          if (curReminder.completed)
            $scope.completedReminders.push(curReminder)
          else
            $scope.reminders.push(curReminder)
    , (err) ->

  $scope.saveCurReminder = (curReminder) ->
    $scope.errors = {}
#        $scope.buttonDisabled = true
    reminder_date = new Date(curReminder._date)
    if curReminder._time != undefined
      reminder_time = new Date(curReminder._time)
      reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
    curReminder.remind_on = reminder_date
#        delete curReminder._date
#        delete curReminder._time
#        delete curReminder.created_at
#        delete curReminder.updated_at
#        delete curReminder.deleted_at
    Reminder.update(id: curReminder.id, reminder: curReminder)
    .then (reminder) ->
      $scope.remindersInit()
    , (err) ->
#                $scope.buttonDisabled = false

  $scope.deleteCurReminder = (curReminder) ->
    $scope.errors = {}
    #        $scope.buttonDisabled = true
    Reminder.delete(curReminder.id)
    .then (reminder) ->
      $scope.remindersInit()
    , (err) ->
#                $scope.buttonDisabled = false

  $scope.remindersInit()

]
