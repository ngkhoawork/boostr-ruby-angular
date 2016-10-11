@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', '$location', '$anchorScroll', '$sce', 'Deal', 'Product', 'DealProduct', 'DealProductBudget', 'DealMember', 'Stage', 'User', 'Field', 'Activity', 'Contact', 'ActivityType', 'Reminder', '$http'
($scope, $routeParams, $modal, $filter, $location, $anchorScroll, $sce, Deal, Product, DealProduct, DealProductBudget, DealMember, Stage, User, Field, Activity, Contact, ActivityType, Reminder, $http) ->

  $scope.showMeridian = true
  $scope.feedName = 'Deal Updates'
  $scope.types = []
  $scope.contacts = []
  $scope.errors = {}
  $scope.contactSearchText = ""

  $scope.init = ->
    $scope.actRemColl = false;
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal)
      $scope.activities = deal.activities

    $scope.anchors = [{name: 'campaign', id: 'campaign'},
                      {name: 'activities', id: 'activities'},
                      {name: 'team & split', id: 'teamsplit'},
                      {name: 'documents', id: 'documents'},
                      {name: 'additional info', id: 'info'}]

    $scope.initActivity()

  $scope.initReminder = ->
    $scope.showReminder = false;

    $scope.reminder = {
      name: '',
      comment: '',
      completed: false,
      remind_on: '',
      remindable_id: $routeParams.id,
      remindable_type: 'Deal' # "Activity", "Client", "Contact", "Deal"
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
          if (reminder && reminder.id && reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
            $scope.reminder.id = reminder.id
            $scope.reminder.name = reminder.name
            $scope.reminder.comment = reminder.comment
            $scope.reminder.completed = reminder.completed
            $scope.reminder._date = new Date(reminder.remind_on)
            $scope.reminder._time = new Date(reminder.remind_on)
            $scope.reminderOptions.editMode = true

  $scope.initReminder()

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

  $scope.initActivity = ->
    $scope.activity = {}
    $scope.activeTab = {}
    $scope.selectedObj = {}
    $scope.selectedObj.deal = true
    $scope.selected = {}
    $scope.populateContact = false
    now = new Date
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.activeType = activityTypes[0]
      _.each activityTypes, (type) ->
        $scope.selected[type.name] = {}
        $scope.selected[type.name].date = now
        $scope.selected[type.name].contacts = []

    $scope.activityReminderInit()

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal
    Contact.query().$promise.then (contacts) ->
      $scope.contacts = contacts
#    Contact.allForClient deal.advertiser_id, (contacts) ->
#      $scope.contacts = contacts

  $scope.getStages = ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = stages

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.months.push({ value: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all().then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

  $scope.$watch 'deal_product.budget', ->
    budget = $scope.deal_product.budget / $scope.currentDeal.days
    _.each $scope.deal_product.months, (month, index) ->
      month.value = $filter('currency')($scope.currentDeal.days_per_month[index] * budget, '$', 0)

  $scope.addProduct = ->
    DealProduct.create(deal_id: $scope.currentDeal.id, deal_product: $scope.deal_product).then (deal) ->
      $scope.showProductForm = false
      $scope.currentDeal = deal

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      months: []
    }

  $scope.showLinkExistingUser = ->
    User.query().$promise.then (users) ->
      $scope.users = $filter('notIn')(users, $scope.currentDeal.members, 'user_id')

  $scope.linkExistingUser = (item) ->
    $scope.userToLink = undefined
    DealMember.create(deal_id: $scope.currentDeal.id, deal_member: { user_id: item.id, share: 0, values: [] }).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDeal = ->
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealStage = (currentDeal) ->
    if currentDeal != null
      Stage.get(id: currentDeal.stage_id).$promise.then (stage) ->
        if !stage.open
          $scope.showModal(currentDeal)
        else
          Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
            if currentDeal.close_reason.option == undefined
              $scope.setCurrentDeal(deal)
            else
              $scope.init()

  $scope.updateDealProductBudget = (data) ->
    DealProductBudget.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product_budget: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealProduct = (data) ->
    DealProduct.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealMember = (data) ->
    DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      DealMember.delete(id: member.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.deleteDealProduct = (deal_product) ->
    if confirm('Are you sure you want to delete "' +  deal_product.name + '"?')
      DealProduct.delete(id: deal_product.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.isActive = (id) ->
    $scope.activeAnchor == id

  $scope.scrollTo = (id) ->
    $scope.activeAnchor = id
    $anchorScroll(id)

  $scope.cancelAddProduct = ->
    $scope.showProductForm = !$scope.showProductForm

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
  $scope.addContact = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_add_form.html'
      size: 'md'
      controller: 'ContactsAddController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          $scope.currentDeal
    .result.then (updatedContact) ->
      $scope.currentDeal.contacts = angular.copy updatedContact

  $scope.$on 'updated_deal', ->
    $scope.init()

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.init()

  $scope.setActiveTab = (tab) ->
    $scope.activeTab = tab

  $scope.setActiveType = (type) ->
    $scope.activeType = type

  $scope.submitForm = (form) ->
    $scope.errors = {}
    $scope.buttonDisabled = true
    if form.$valid
      if !$scope.activity.comment
        $scope.buttonDisabled = false
        $scope.errors['Comment'] = ["can't be blank."]
      if !($scope.activeType && $scope.activeType.id)
        $scope.buttonDisabled = false
        $scope.errors['Activity Type'] = ["can't be blank."]
      data = $scope.selected[$scope.activeType.name]
      if !data.contacts || data.contacts.length == 0
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
      form.submitted = true
      $scope.activity.deal_id = $scope.currentDeal.id

      $scope.activity.client_id = $scope.currentDeal.advertiser_id
      $scope.activity.agency_id = $scope.currentDeal.agency_id
      $scope.activity.activity_type_id = $scope.activeType.id
      $scope.activity.activity_type_name = $scope.activeType.name
      contact_date = new Date(data.date)
      if data.time != undefined
        contact_time = new Date(data.time)
        contact_date.setHours(contact_time.getHours(), contact_time.getMinutes(), 0, 0)
        $scope.activity.timed = true
      $scope.activity.happened_at = contact_date
      Activity.create({ activity: $scope.activity, contacts: data.contacts }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
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
#          .then (reminder) ->
#          , (err) ->

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

  $scope.cancelActivity = ->
    $scope.initActivity()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.contacts.push contact
      $scope.selected[$scope.activeType.name].contacts.push(contact.id)
      $scope.populateContact = false

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_activities')
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
#          $scope.itemId
#        itemType: ->
#          $scope.itemType

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

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)
]
