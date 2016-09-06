@app.controller 'DashboardController',
['$scope', '$http', '$modal', '$sce', 'Dashboard', 'Deal', 'Client', 'Contact', 'Activity', 'ActivityType', 'Reminder', 'Stage',
($scope, $http, $modal, $sce, Dashboard, Deal, Client, Contact, Activity, ActivityType, Reminder, Stage) ->

  $scope.showMeridian = true
  $scope.feedName = 'Activity Updates'
  $scope.moreSize = 10;
  $scope.types = []
  $scope.contactActionLog = []
  $scope.loadMoreActivitiesText = "Load More"
  $scope.loadingMoreActivities = false

  $scope.showSpinners = (reminder) ->
    reminder.showSpinners = true
    console.log('reminder', reminder)

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
    $scope.getStages()

    $scope.actRemColl = false;

    $scope.reminder = {
      name: '',
      comment: '',
      completed: false,
      remind_on: '',
      remindable_id: 0,
      remindable_type: 'Activity' # "Activity", "Client", "Contact", "Deal"
      _date: new Date(),
      _time: new Date(),
      showSpinners: false
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
    Activity.all({page: 1, filter: "client"}).then (activities) ->
      $scope.activities = activities
      if activities.length == 10
        $scope.hasMoreActivities = true
      $scope.nextActivitiesPage = 2


    Contact.all1(unassigned: "yes").then (contacts) ->
      $scope.unassignedContacts = contacts
      $scope.contactNotification = {}
      _.each $scope.unassignedContacts, (contact) ->
        $scope.contactNotification[contact.id] = ""

    Contact.$resource.query().$promise.then (contacts) ->
      $scope.contacts = contacts
    Dashboard.get().then (dashboard) ->
      $scope.dashboard = dashboard
      $scope.forecast = dashboard.forecast
      $scope.setChartData()

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

  $scope.loadMoreActivities = ->
    if $scope.loadingMoreActivities == false
      $scope.loadingMoreActivities = true
      $scope.loadMoreActivitiesText = "Loading ..."
      Activity.all({page: $scope.nextActivitiesPage, filter: "client"}).then (activities) ->
        $scope.activities = $scope.activities.concat(activities)
        if activities.length == 10
          $scope.hasMoreActivities = true
        $scope.nextActivitiesPage = $scope.nextActivitiesPage + 1
        $scope.loadingMoreActivities = false
        $scope.loadMoreActivitiesText = "Load More"

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

  $scope.showAssignContactModal = (contact) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_assign_form.html'
      size: 'md'
      controller: 'ContactsAssignController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          contact
    .result.then (updated_contact) ->
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

  $scope.saveCurrentContact = (contact) ->
    Contact.update(id: contact.id, contact: contact).then (updated_contact) ->
      $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
        if (item.id == updated_contact.id)
          return updated_contact
        else
          return item
  $scope.undoAssignContact = (contact) ->
    previousContact = _.find $scope.unassignedContacts, (item) ->
      return item.id == contact.id
    Contact.update(id: contact.id, contact: contact).then (updated_contact) ->
      $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
        if (item.id == updated_contact.id)
          return updated_contact
        else
          return item


      if updated_contact.client
        $scope.contactNotification[updated_contact.id] = "Assigned to " + updated_contact.client.name
        $scope.contactActionLog.push({
          previousContact: previousContact,
          message: updated_contact.client.name
        })
      else
        $scope.contactNotification[updated_contact.id] = "Unassigned"
        $scope.contactActionLog.push({
          previousContact: previousContact,
          message: ""
        })

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
  $scope.getStages = ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = stages

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
      Activity.create({ activity: $scope.activity, contacts: $scope.selected[$scope.activeType.name].contacts }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (activity) ->
        if (activity && activity.id && $scope.actRemColl)
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

  $scope.updateDealStage = (currentDeal) ->
    if currentDeal != null
      Stage.get(id: currentDeal.stage_id).$promise.then (stage) ->
        if !stage.open
          $scope.showModal(currentDeal)
        else
          Deal.update(id: currentDeal.id, deal: currentDeal).then (deal) ->
            $scope.init()

  $scope.showModal = (currentDeal) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_close_form.html'
      size: 'lg'
      controller: 'DealsCloseController'
      backdrop: 'static'
      keyboard: false
      resolve:
        currentDeal: ->
          currentDeal

  $scope.$on 'updated_deal', ->
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
          curReminder.showSpinners = false
          now = new Date();
          yearDiff = curReminder._date.getFullYear() - now.getFullYear()
          monthDiff = curReminder._date.getMonth() - now.getMonth()
          dayDiff = curReminder._date.getDate() - now.getDate()
          if yearDiff > 0
            curReminder.dateColorClass = 'silver'
          else if yearDiff < 0
            curReminder.dateColorClass = 'red'
          else
            if monthDiff > 0
              curReminder.dateColorClass = 'silver'
            else if monthDiff < 0
              curReminder.dateColorClass = 'red'
            else
              if dayDiff > 1
                curReminder.dateColorClass = 'silver'
              else if dayDiff == 1
                curReminder.dateColorClass = 'yellow'
              else
                curReminder.dateColorClass = 'red'
#          timeDiff = curReminder._date.getTime() - now.getTime();
#          diffDays = timeDiff / (1000 * 3600 * 24);
#          if (diffDays <= 1 )
#            curReminder.dateColorClass = 'red';
#          if (diffDays > 1  && diffDays < 2)
#            curReminder.dateColorClass = 'yellow';
#          if (diffDays >= 2 )
#            curReminder.dateColorClass = 'silver';
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
#    .then (reminder) ->
#
#    , (err) ->

  $scope.saveReminder = (curReminder) ->
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

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)
]
