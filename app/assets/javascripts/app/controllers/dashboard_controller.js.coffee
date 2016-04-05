@app.controller 'DashboardController',
['$scope', '$http', '$modal', 'Dashboard', 'Deal', 'Client', 'Contact', 'Activity',
($scope, $http, $modal, Dashboard, Deal, Client, Contact, Activity) ->

  $scope.showMeridian = true

  $scope.types = [
    {'name':'Initial Meeting', 'action':'Initial meeting with'},
    {'name':'Pitch', 'action':'Pitched to'},
    {'name':'Proposal Sent', 'action':'Sent proposal to'},
    {'name':'Feedback', 'action':'Agency/Client feedback from'},
    {'name':'Agency Meeting', 'action':'Agency meeting with'},
    {'name':'Client Meeting', 'action':'Client meeting with'},
    {'name':'Client Entertainment', 'action':'Client entertainment with'},
    {'name':'Campaign Review', 'action':'Reviewed campaign with'},
    {'name':'QBR', 'action':'Quarterly Business Review with'}
  ]

  $scope.init = ->
    $scope.activity = {}
    $scope.activeTab = 'Object'
    $scope.selectedObj = {}
    $scope.selectedObj.deal = true
    $scope.selected = {}
    now = new Date
    _.each $scope.types, (type) -> 
      $scope.selected[type.name] = {}
      $scope.selected[type.name].date = now
    $scope.activeType = $scope.types[0]
 
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

  $scope.setActiveTab = (tab) ->
    $scope.activeTab = tab

  $scope.setActiveType = (type) ->
    $scope.activeType = type

  $scope.$on 'updated_dashboards', ->
    $scope.init()

  $scope.init()

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
      else
        contact_date.setHours(-7, 0, 0, 0)
      $scope.activity.happened_at = contact_date
      Activity.create({ activity: $scope.activity }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (activity) ->
        $scope.buttonDisabled = false
        $scope.init()

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

]
