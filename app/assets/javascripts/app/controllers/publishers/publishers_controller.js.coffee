@app.controller 'PablishersController', [
  '$scope', 'Publisher', 'PublishersFilter',
  ($scope,   Publisher,   PublishersFilter) ->
    $scope.publishers = []
    $scope.publisherTypes = [
      {name: 'All'}
      {name: 'My Publishers', my_publishers_bool: true}
      {name: 'My Team\'s publishers', my_team_publishers_bool: true}
    ]

    $scope.filter =
      stages: []
      types: []
      comscores: [
        {name: 'Active', value: true}
        {name: 'Inactive', value: false}
      ]
      isOpen: false
      search: ''
      selected: PublishersFilter.selected
      get: ->
        s = this.selected
        filter = {}
        filter.comscore = s.comscore.value if _.isBoolean s.comscore.value
        filter.publisher_stage_id = s.stage.id if s.stage
        filter.type_id = s.type.id if s.type
        filter
      apply: (reset) ->
        $scope.getPublishers()
        if !reset then this.isOpen = false
      searching: (item) ->
        if !item then return false
        if item.name
          return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
        else
          return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
      reset: (key) ->
        PublishersFilter.reset(key)
      resetAll: ->
        PublishersFilter.resetAll()
      select: (key, value) ->
        PublishersFilter.select(key, value)
      onDropdownToggle: ->
        this.search = ''
      open: ->
        this.isOpen = true
      close: ->
        this.isOpen = false

    $scope.init = ->
      $scope.teamFilter = $scope.publisherTypes[0]
      $scope.getPublishers()
      $scope.getPublisherSettings()

    $scope.filterPublishers = (type) ->
      $scope.teamFilter = type
      $scope.getPublishers()

    $scope.getPublisherSettings = () ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_stages = $scope.filter.stages = settings.publisher_stages
        $scope.publisher_types = $scope.filter.types = settings.publisher_types

    $scope.getPublishers = ->
      params = {}
      params.q = $scope.searchText if $scope.searchText
      params = _.extend(
          params
          $scope.filter.get()
          _.omit $scope.teamFilter, 'name'
      )
      Publisher.publishersList(params).then (publishers) ->
        console.log(publishers)
        $scope.publishers = publishers

    $scope.updatePublisher = (publisher) ->
      params = { comscore: publisher.comscore, type_id: publisher.type.id }

      if publisher.publisher_stage
        params.publisher_stage_id = publisher.publisher_stage.id

      Publisher.update(id: publisher.id, publisher: params)


    $scope.showNewPublisherModal = ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_form.html'
        size: 'md'
        controller: 'PablisherNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          publisher: ->
            {}
            
    $scope.init()
]
