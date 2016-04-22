@app.controller 'DashboardController',
['$scope', '$http', '$modal', 'Dashboard', 'Deal', 'Client', 'Contact', 'Activity',
($scope, $http, $modal, Dashboard, Deal, Client, Contact, Activity) ->

  $scope.showMeridian = true
  $scope.types = Activity.types
  $scope.feedName = 'Updates'
  $scope.moreSize = 10;

  $scope.init = ->
    $scope.currentPage = 0;
    $scope.activity = {}
    $scope.activeTab = {}
    $scope.selectedObj = {}
    $scope.selectedObj.deal = true
    $scope.selected = {}
    now = new Date
    _.each $scope.types, (type) -> 
      $scope.selected[type.name] = {}
      $scope.selected[type.name].date = now
    $scope.activeType = $scope.types[0]
    $scope.populateContact = false
    Activity.all().then (activities) ->
      $scope.activities = activities
    $scope.activity_objects = []
    Deal.all({activity: true}).then (deals) ->
      _.each deals, (object) ->
        object.currentLimit = $scope.moreSize
        $scope.activity_objects = $scope.activity_objects.concat object
    Client.all({activity: true}).then (clients) ->
      _.each clients, (object) ->
        object.currentLimit = $scope.moreSize
        $scope.activity_objects = $scope.activity_objects.concat object

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
      Client.all({name: name}).then (clients) ->
        clients

  $scope.searchContact = (name) ->
    Contact.all1({name: name}).then (contacts) ->
      contacts

  $scope.submitForm = (form) ->
    $scope.buttonDisabled = true
    if form.$valid
      if $scope.selectedObj.obj == undefined
        $scope.buttonDisabled = false
        return
      if $scope.selectedObj.deal
        $scope.activity.deal_id = $scope.selectedObj.obj.id
        $scope.activity.client_id = $scope.selectedObj.obj.advertiser_id
      else
        $scope.activity.client_id = $scope.selectedObj.obj.id
      if $scope.selected[$scope.activeType.name].contact == undefined
        $scope.buttonDisabled = false
        return
      form.submitted = true
      $scope.activity.activity_type = $scope.activeType.name
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

  $scope.getIndex = (object) ->
    $scope.activity_objects.indexOf(object)

  $scope.toggleActivity = (object) ->
    i = $scope.getIndex(object)
    if $scope.activity_objects[i].show == undefined || !$scope.activity_objects[i].show
      $scope.activity_objects[i].show = true
    else
      $scope.activity_objects[i].show = false
]
