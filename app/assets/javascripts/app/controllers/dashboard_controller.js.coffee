@app.controller 'DashboardController',
['$scope', '$http', '$modal', 'Dashboard', 'Deal', 'Client', 'Contact', 'Activity', 'ActivityType',
($scope, $http, $modal, Dashboard, Deal, Client, Contact, Activity, ActivityType) ->

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
    now = new Date
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.activeType = activityTypes[0]
      _.each activityTypes, (type) ->
        $scope.selected[type.name] = {}
        $scope.selected[type.name].date = now

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

  $scope.searchContact = (name) ->
    Contact.all1({name: name}).then (contacts) ->
      contacts

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    if form.$valid
      if $scope.selectedObj.obj != undefined
        if $scope.selectedObj.deal
          $scope.activity.deal_id = $scope.selectedObj.obj.id
          $scope.activity.client_id = $scope.selectedObj.obj.advertiser_id
        else
          $scope.activity.client_id = $scope.selectedObj.obj.id
      if $scope.selected[$scope.activeType.name].contact == undefined
        $scope.buttonDisabled = false
        return
      form.submitted = true
      $scope.activity.activity_type_id = $scope.activeType.id
      $scope.activity.activity_type_name = $scope.activeType.name
      contact_id = $scope.selected[$scope.activeType.name].contact.id
      $scope.activity.contact_id = contact_id
      contact_date = new Date($scope.selected[$scope.activeType.name].date)
      if $scope.selected[$scope.activeType.name].time != undefined
        contact_time = new Date($scope.selected[$scope.activeType.name].time)
        contact_date.setHours(contact_time.getHours(), contact_time.getMinutes(), 0, 0)
        $scope.activity.timed = true
      $scope.activity.happened_at = contact_date
      Activity.create({ activity: $scope.activity }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
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

  $scope.cancelActivity = ->
    $scope.init()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.selected[$scope.activeType.name].contact = contact
      $scope.populateContact = false

  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)
]
