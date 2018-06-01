@app.controller 'AccountsController',
['$scope', '$filter', '$timeout', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$sce', 'Client', 'ClientMember', 'Contact', 'Deal', 'Field', 'Activity', 'ActivityType', 'Reminder', '$http', 'ClientContacts', 'ClientsTypes', 'AccountsFilter', 'CurrentUser'
($scope, $filter, $timeout, $rootScope, $modal, $routeParams, $location, $window, $sce, Client, ClientMember, Contact, Deal, Field, Activity, ActivityType, Reminder, $http, ClientContacts, ClientsTypes, AccountsFilter, CurrentUser) ->
  $scope.scrollCallback = -> $timeout -> $scope.$emit 'lazy:scroll'
  formatMoney = $filter('formatMoney')
  $scope.query = ""
  $scope.page = 1
  $scope.clientsPerPage = 10
  $scope.isLoading = false
  $scope.isClientsLoading = false
  $scope.allClientsLoaded = false
  $scope.allow_edit = false;
  $scope.accountTypes = [
    {name: 'My Accounts', param: ''}
    {name: 'My Team\'s Accounts', param: 'team'}
    {name: 'All', param: 'all'}
  ]

  $scope.checkPermissions = ->
    if !$scope.currentUser.is_admin && $scope.currentClient.is_multibuyer
      $scope.allow_edit = false
    else if $scope.currentUser.is_admin && $scope.currentClient.is_multibuyer
      $scope.allow_edit = true
    else
      $scope.allow_edit = true

  $scope.teamFilter = (value) ->
    if value then AccountsFilter.teamFilter = value else AccountsFilter.teamFilter

  $scope.filter =
    owners: []
    categories: []
    regions: []
    segments: []
    types: []
    isOpen: false
    isEndDateOpen: false
    isStartDateOpen: false
    search: ''
    selected: AccountsFilter.selected
    datePicker:
      date:
        startDate: null
        endDate: null
      apply: ->
        _this = $scope.filter.datePicker
        if (_this.date.startDate && _this.date.endDate)
          $scope.filter.selected.date = _this.date
    apply: (reset) ->
      selected = this.selected

      $scope.page = 1
      $scope.getClients($scope.scrollCallback)
      if !reset then this.isOpen = false
    reset: (key) ->
      AccountsFilter.reset(key)
    resetAll: ->
      AccountsFilter.resetAll()
#      this.apply(true)
    getBudgetValue: ->
      budget = this.selected.budget
      if budget.min && !budget.max
        return 'From ' + formatMoney(budget.min)
      if !budget.min && budget.max
        return 'To ' + formatMoney(budget.max)
      if budget.min && budget.max
        return formatMoney(budget.min) + ' - ' + formatMoney(budget.max)
      return 'Budget'
    getDateValue: ->
      date = this.selected.date
      if date.startDate && date.endDate
        return """#{date.startDate.format('MMMM D, YYYY')} -\n#{date.endDate.format('MMMM D, YYYY')}"""
      return 'Time period'
    select: (key, value) ->
      AccountsFilter.select(key, value)
    onDropdownToggle: ->
      this.search = ''
    open: (event) ->
#                    event.stopPropagation()
      this.isOpen = true
    close: (event) ->
#                    event.stopPropagation()
      this.isOpen = false

  searchTimeout = null
  $scope.handleSearch = () ->
    $scope.page = 1
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients($scope.scrollCallback)
      400
    )

  $scope.filtering = (item) ->
    if !item then return false
    if item.name
      return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
    else
      return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1

  $scope.filterAccounts = (filter) ->
    $scope.teamFilter filter
    $scope.page = 1
    $scope.getClients($scope.scrollCallback)
    $scope.getFilterOptions()

  $scope.loadMoreClients = ->
    if !$scope.allClientsLoaded then $scope.getClients()

  $scope.init = ->
    if !$scope.teamFilter() then $scope.teamFilter $scope.accountTypes[0]
    $scope.page = 1
    $scope.getClients()
    $scope.getFilterOptions()
    Field.defaults({}, 'Client').then (fields) ->
      $scope.filter.types = Field.findFieldOptions(fields, 'Client Type')
      $scope.filter.categories = Field.findFieldOptions(fields, 'Category')
      $scope.filter.regions = Field.findFieldOptions(fields, 'Region')
      $scope.filter.segments = Field.findFieldOptions(fields, 'Segment')

  $scope.getClients = (callback) ->
    $scope.isClientsLoading = true
    params = {
      filter: $scope.teamFilter().param,
      search: $scope.searchText,
      page: $scope.page
    }
    if $scope.filter.selected.category
      params.client_category_id = $scope.filter.selected.category.id
    if $scope.filter.selected.region
      params.client_region_id = $scope.filter.selected.region.id
    if $scope.filter.selected.segment
      params.client_segment_id = $scope.filter.selected.segment.id
    if $scope.filter.selected.type
      params.client_type_id = $scope.filter.selected.type.id
    if $scope.filter.selected.city
      params.city = $scope.filter.selected.city
    if $scope.filter.selected.owner
      params.owner_id = $scope.filter.selected.owner.id
    if $scope.filter.selected.date
      params.start_date = $scope.filter.selected.date.startDate.add($scope.filter.selected.date.startDate.utcOffset(), 'm') if $scope.filter.selected.date.startDate
      params.end_date = $scope.filter.selected.date.endDate.add($scope.filter.selected.date.endDate.utcOffset(), 'm') if $scope.filter.selected.date.endDate
    if $scope.query.trim().length
      params.name = $scope.query.trim()

    Client.query(params).$promise.then (clients) ->
      $scope.allClientsLoaded = !clients || clients.length < $scope.clientsPerPage
#      if $scope.page == 2 then clients.shift()
      clients = addMissingClientFields(clients)
      if $scope.page++ > 1
        $scope.clients = $scope.clients.concat(clients)
      else
        $scope.clients = clients
      $scope.isClientsLoading = false
      callback() if _.isFunction callback

  addMissingClientFields = (clients) ->
    _.map clients, (client) ->
      client._lastTouch = $scope.getLastTouch(client)
      client

  $scope.getFilterOptions = ->
    $scope.isLoading = true
    params = {
      filter: $scope.teamFilter().param,
    }
    Client.filter_options(params).$promise.then (response) ->
      $scope.filter.owners = response.owners
      $scope.filter.cities = response.cities
      $scope.isLoading = false

  $scope.getLastTouch = (client) ->
    if client.type == 'Advertiser'
      client.latest_advertiser_activity
    else if client.type == 'Agency'
      client.latest_agency_activity
    else
      ''

  $scope.showNewAccountModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: -> {}
        options: -> {}

  $scope.go = (client_id) ->
    $location.path('/accounts/' + client_id)
  $scope.$on 'newClient', ->
    $scope.init()
  $scope.init()


]
