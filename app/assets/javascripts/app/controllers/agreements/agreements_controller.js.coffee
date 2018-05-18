@app.controller 'AgreementsController',
['$scope', '$filter', '$window', '$timeout', '$modal', 'localStorageService', 'Agreement', 'AgreementsFilter', 'CustomValue', 'Client'
($scope, $filter, $window, $timeout, $modal, localStorageService, Agreement, AgreementsFilter, CustomValue, Client) ->
  init = ->
    $scope.getAgreements()
    $scope.filter.getFilterOptions()
    
  formatMoney = $filter('formatMoney')
  $scope.searchQuery = ""
  $scope.agreements = []
  page = 1
  agreementsPerPage = 10
  $scope.allAgreementsLoaded = false
  $scope.isAgreementsLoading = false
  $scope.scrollCallback = -> $timeout -> $scope.$emit 'lazy:scroll'

  $scope.switches = [
    {name: 'My Agreements', param: 'my_agreements'}
    {name: 'My Team\'s Agreements', param: 'team'}
    {name: 'All', param: ''}
  ]

  $scope.teamFilter = (value) ->
    AgreementsFilter.teamFilter = value if value
    localStorageService.set('agreementTeamFilter', AgreementsFilter.teamFilter)
    AgreementsFilter.teamFilter

  unless localStorageService.get('agreementTeamFilter')
    $scope.teamFilter $scope.switches[0]
  else
    agreementTeamFilter = localStorageService.get('agreementTeamFilter')
    $scope.teamFilter agreementTeamFilter

  $scope.filter =
    isOpen: false
    search: ''
    selected: AgreementsFilter.selected
    names: []
    agreementTypes: []
    statuses: []
    clients: []
    minTarget: null
    maxTarget: null  
    tracks: ['Auto', 'Manual']
    datePicker:
      date:
          startDate: null
          endDate: null
      applyDate: ->
          _this = $scope.filter.datePicker
          if (_this.date.startDate && _this.date.endDate)
              $scope.filter.selected.date = _this.date
    
    getDateValue: (key) ->
      date = this.selected[key]
      if date.startDate && date.endDate
          return "#{date.startDate.format('MMM D, YYYY')} -\n#{date.endDate.format('MMM D, YYYY')}"
      return 'From - To'

    slider:
      minValue: 0
      maxValue: 0
      options:
        floor: 0
        ceil: 100000000
        minRange: 0
        pushRange: true

        translate: (value) -> formatMoney(value)

        onChange: (slideId, minValue, maxValue, type) ->
          if !$scope.filter.selected.target then $scope.filter.selected.target = {}
          target = $scope.filter.selected.target
          if minValue && maxValue
            target.min = $scope.filter.minTarget = Math.min(minValue, maxValue)
            target.max = $scope.filter.maxTarget = Math.max(minValue, maxValue)
          else
            target.min = $scope.filter.minTarget = minValue
            target.max = $scope.filter.maxTarget = maxValue
          if this.maxValue is 0 then this.maxValue = this.options.ceil

      onChangeNumber: (type) ->
        if !$scope.filter.selected.target then $scope.filter.selected.target = {}
        target = $scope.filter.selected.target
        $scope.filter.minTarget = parseInt($scope.filter.minTarget) || 0
        $scope.filter.maxTarget = parseInt($scope.filter.maxTarget) || 0
        switch type
          when 'min'
            if $scope.filter.minTarget > this.options.ceil
              $scope.filter.minTarget = this.options.ceil
          when 'max'
            if $scope.filter.maxTarget > this.options.ceil
              $scope.filter.maxTarget = this.options.ceil

        if $scope.filter.minTarget && $scope.filter.maxTarget
          target.min = this.minValue = Math.min($scope.filter.minTarget, $scope.filter.maxTarget)
          target.max = this.maxValue = Math.max($scope.filter.minTarget, $scope.filter.maxTarget)
        else
          target.min = this.minValue = $scope.filter.minTarget
          target.max = this.maxValue = $scope.filter.maxTarget
        if this.maxValue is 0 then this.maxValue = this.minValue

      refresh: -> $scope.$broadcast 'rzSliderForceRender'        
    
    getTargetValue: ->
      target = this.selected.target
      if target.min && !target.max
        return 'From ' + formatMoney(target.min)
      if !target.min && target.max
        return 'To ' + formatMoney(target.max)
      if target.min && target.max
        return formatMoney(target.min) + ' - ' + formatMoney(target.max)
      return 'Target'

    get: ->
      s = this.selected
      filter = {}
      filter.q = s.name if s.name
      filter.type_id = s.agreementType.id if s.agreementType
      filter.status_id = s.status.id if s.status
      filter['by_client_ids[]'] = [s.client.id] if s.client
      filter.start_date = s.date.startDate.format() if s.date.startDate
      filter.end_date = s.date.endDate.format() if s.date.endDate
      filter.min_target = s.target.min if s.target
      filter.max_target = s.target.max if s.target
      if s.track
        filter.manually_tracked = if s.track == "Manual" then true else false
      filter

    apply: (reset) ->
      page = 1
      $scope.getAgreements($scope.scrollCallback)
      if !reset then this.isOpen = false

    searching: (item) ->
      if !item then return false
      if item.name
        return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
      else
        return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
    
    reset: (key) -> AgreementsFilter.reset(key)
    
    resetAll: -> AgreementsFilter.resetAll()
    
    select: (key, value) -> AgreementsFilter.select(key, value)
    
    onDropdownToggle: -> this.search = ''
    
    open: -> this.isOpen = true
    
    close: -> this.isOpen = false

    getFilterOptions: ->
      CustomValue.all().then (custom_values) ->
        custom_values.forEach (value) ->
          if value.name == 'Multiple'
            value.fields.forEach (field) ->
              if field.name == 'Spend Agreement Status'
                $scope.filter.statuses = field.options
              if field.name == 'Spend Agreement Type'
                $scope.filter.agreementTypes = field.options

      $scope.filter.tracks = ["Manual", "Auto"]
      $scope.searchClients()
      $scope.getAgreementsNames()

  $scope.searchClients = (search = '') ->
    Client.query(search: search, filter: 'all').$promise.then (clients) ->
      $scope.filter.clients = clients

  $scope.loadMoreAgreements = ->
    if !$scope.allAgreementsLoaded
      $scope.getAgreements()

  $scope.handleSearch = () ->
    page = 1
    if !$scope.isAgreementsLoading
      $scope.getAgreements($scope.scrollCallback)

  $scope.getAgreements = (callback) ->
    $scope.isAgreementsLoading = true
    query = $scope.filter.get()
    switch AgreementsFilter.teamFilter.param
      when 'team'
        query.my_teams_records = true
      when 'my_agreements'
        query.my_records = true
    query.page = page
    query.per = agreementsPerPage
    if $scope.searchQuery && !query.q
      query.q =  $scope.searchQuery
    Agreement.query query, (agreements) ->
      $scope.allAgreementsLoaded = !agreements || agreements.length < agreementsPerPage
      agreements.forEach (agreement) ->
        agreement.allAdvertisers = agreement.parent_companies.concat(agreement.advertisers)
      if page++ > 1
        $scope.agreements = $scope.agreements.concat(agreements)
      else
        $scope.agreements = agreements
      $scope.isAgreementsLoading = false
      callback() if _.isFunction callback

  $scope.getAgreementsNames = (search = '') ->
    query = { per: 10, page: 1 }
    query.q = search if search
    Agreement.query query, (data) ->
      $scope.filter.names = data.map (agreement) ->
        { name: agreement.name, id: agreement.id } 

  $scope.showNewAgreementModal = ->
    $modal.open
      templateUrl: 'modals/agreements_add.html'
      size: 'md'
      controller: 'AgreementsAddController'
      backdrop: 'static'
      keyboard: false
      resolve:
        options: -> null

  $scope.showEditAgreementModal = (agreement) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/agreement/agreement_edit.html'
      size: 'md'
      controller: 'AgreementEditController'
      backdrop: 'static'
      keyboard: false
      resolve: 
        agreement: -> agreement
    .result.then (editedAgreement) -> updateAgreement(editedAgreement) if editedAgreement

  updateAgreement = (editedAgreement) ->
    index = _.findIndex $scope.agreements, {id: editedAgreement.id}
    $scope.agreements[index] = editedAgreement

  $scope.switchAgreements = (swch) ->
    $scope.teamFilter swch
    page = 1
    $scope.getAgreements($scope.scrollCallback)

  $scope.toggleDrodown = (event) ->
    dropdown = angular.element(event.target).next()
    tableWrapper = angular.element('table').parent()

    if dropdown.is(':visible')
      dropdown.hide()
      tableWrapper.addClass('table-wrapper')
      return
    else
      multipleLists = angular.element('.multiple-list-wrapper')
      multipleLists.hide()
      dropdown.show()
      tableWrapper.removeClass('table-wrapper')
      return

  $window.addEventListener 'click', (event) ->
    target = angular.element(event.target)
    if target.closest(".multiple").length == 0
      multipleLists = angular.element('.multiple-list-wrapper')
      multipleLists.hide()

  init()
]
