@app.controller 'AccountsController',
['$scope', '$filter', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$sce', 'Client', 'ClientMember', 'Contact', 'Deal', 'Field', 'Activity', 'ActivityType', 'Reminder', '$http', 'ClientContacts', 'ClientsTypes', 'AccountsFilter'
($scope, $filter, $rootScope, $modal, $routeParams, $location, $window, $sce, Client, ClientMember, Contact, Deal, Field, Activity, ActivityType, Reminder, $http, ClientContacts, ClientsTypes, AccountsFilter) ->
  formatMoney = $filter('formatMoney')
  $scope.selectedType = 0
  $scope.query = ""
  $scope.page = 1
  $scope.accountTypes = [
    {name: 'My Accounts', param: ''}
    {name: 'My Team\'s Accounts', param: 'team'}
    {name: 'All', param: 'company'}
  ]

  $scope.filter =
    owners: []
    categories: []
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
      $scope.getClients()
      if !reset then this.isOpen = false
    reset: (key) ->
      AccountsFilter.reset(key)
    resetAll: ->
      AccountsFilter.resetAll()
      this.apply(true)
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

  $scope.filtering = (item) ->
    if !item then return false
    if item.name
      return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
    else
      return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1

  $scope.filterAccounts = (filter) ->
    $scope.selectedType = filter
    $scope.page = 1
    $scope.getClients()
    $scope.getFilterOptions()

  $scope.isLoading = false

  $scope.loadMoreClients = ->
    if !$scope.isLoading && $scope.clients && $scope.clients.length < Client.totalCount
      $scope.page = $scope.page + 1
      $scope.getClients()

  $scope.init = ->
    $scope.selectedType = $scope.accountTypes[0]
    $scope.page = 1
    $scope.getClients()
    $scope.getFilterOptions()
    Field.defaults({}, 'Client').then (fields) ->
      $scope.filter.types = Field.findFieldOptions(fields, 'Client Type')
      $scope.filter.categories = Field.findFieldOptions(fields, 'Category')

  $scope.getClients = ->
    $scope.isLoading = true
    params = {
      filter: $scope.selectedType.param,
      page: $scope.page
    }
    if $scope.filter.selected.category
      params.client_category_id = $scope.filter.selected.category.id
    if $scope.filter.selected.type
      params.client_type_id = $scope.filter.selected.type.id
    if $scope.filter.selected.city
      params.city = $scope.filter.selected.city
    if $scope.filter.selected.owner
      params.owner_id = $scope.filter.selected.owner.id
    if $scope.filter.selected.date
      params.start_date = $scope.filter.selected.date.startDate
      params.end_date = $scope.filter.selected.date.endDate
    if $scope.query.trim().length
      params.name = $scope.query.trim()

    Client.query(params).$promise.then (clients) ->
      if $scope.page > 1
        $scope.clients = $scope.clients.concat(clients)
      else
        $scope.clients = clients
      $scope.isLoading = false

  $scope.getFilterOptions = ->
    $scope.isLoading = true
    params = {
      filter: $scope.selectedType.param,
    }
    Client.filter_options(params).$promise.then (response) ->
      $scope.filter.owners = response.owners
      $scope.filter.cities = response.cities
      $scope.isLoading = false

  $scope.getClientType = (client) ->
    clientType = Field.field(client, 'Client Type')
    return clientType.option.name

  $scope.getClientCategory = (client) ->
    clientCategory = Field.getOption(client, 'Category', client.client_category_id)
    if clientCategory
      return clientCategory.name
    else
      return ""

  $scope.getLastTouch = (client) ->
    if client.activities.length > 0
      return client.activities[0].happened_at
    else
      return ""

  $scope.showNewAccountModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {}

  $scope.$on 'newClient', ->
    $scope.init()
  $scope.init()


]
