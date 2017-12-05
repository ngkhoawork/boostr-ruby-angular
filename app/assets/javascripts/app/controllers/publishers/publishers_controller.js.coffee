@app.controller 'PablishersController', [
  '$scope', '$document', '$timeout', '$modal', 'Publisher', 'PublishersFilter', 'shadeColor'
  ($scope,   $document,   $timeout,   $modal,   Publisher,   PublishersFilter,   shadeColor) ->
    $scope.publishers = []
    $scope.publishersPipeline = []
    $scope.view = 'list'
    page = 1
    per = 10
    $scope.isListLoading = false
    $scope.isPipelineLoading = false
    $scope.allPublishersLoaded = false
    $scope.publisherTypes = [
      {name: 'All'}
      {name: 'My Publishers', my_publishers_bool: true}
      {name: 'My Team\'s publishers', my_team_publishers_bool: true}
    ]

    $scope.history =
      set: (id, key, value) ->
        if !this[id] then this[id] = {locked: false}
        if this[id].locked && key is 'from' then return
        if value then this[id][key] = value
      get: (id) ->
        return this[id]
      lock: (id, bool) ->
        if !this[id] then this[id] = {}
        this[id].locked = bool

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

    resetPagination = ->
      $scope.publishers = []
      $scope.publishersPipeline = []
      page = 1
      $scope.isListLoading = false
      $scope.isPipelineLoading = false
      $scope.allPublishersLoaded = false

    $scope.changeView = (view) ->
      $scope.view = view
      resetPagination()
      $scope.getPublishers()

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

    getParams = ->
      params = {per, page}
      params.q = $scope.searchText if $scope.searchText
      params = _.extend(
          params
          $scope.filter.get()
          _.omit $scope.teamFilter, 'name'
      )

    $scope.getPublishers = (nextPage) ->
      if !nextPage then resetPagination()
      params = getParams()
      switch $scope.view
        when 'list'
          getPublishersList(params)
        when 'columns'
          getPublishersPipeline(params)

    getPublishersList = (params) ->
      $scope.isListLoading = true
      Publisher.publishersList(params).then (publishers) ->
        $scope.allPublishersLoaded = !publishers || publishers.length < per
        if page++ > 1
          $scope.publishers = $scope.publishers.concat(publishers)
        else
          $scope.publishers = publishers
        $scope.isListLoading = false
      , ->
        $scope.isListLoading = false

    getPublishersPipeline = (params) ->
      $scope.isPipelineLoading = true
      Publisher.publishersPipeline(params).then (pipeline) ->
        $scope.allPublishersLoaded = !pipeline || _.every pipeline, (stage) -> stage.publishers.length < per
        if page++ > 1
          $scope.publishersPipeline = _.map $scope.publishersPipeline, (stage, i) ->
            stage.publishers = stage.publishers.concat(pipeline[i].publishers)
            stage
        else
          $scope.publishersPipeline = pipeline
        $scope.isListLoading = false
        $timeout -> addScrollEvent()
        $scope.isPipelineLoading = false
      , ->
        $scope.isPipelineLoading = false
        $scope.allPublishersLoaded = true

    $scope.loadMorePublishers = ->
      $scope.getPublishers(true)

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

    $scope.coloringColumns = ->
      baseColor = '#81B130'
      headers = $document.find('.column-header')
      headers.each (i, elem) ->
        color = shadeColor baseColor, 0.8 - 0.8 / (headers.length - 1) * i
        header = angular.element(elem)
        svgPolygon = header.find('polygon')
        header.css('backgroundColor', color)
        svgPolygon.css('fill', color)
      return true

    $scope.onMoved = (publisher, publisherIndex, columnIndex) ->
      $scope.history.set publisher.id, 'from',
        publisher: publisherIndex
        column: columnIndex
      $scope.history.lock(publisher.id, true)

      $scope.publishersPipeline[columnIndex].publishers.splice(publisherIndex, 1)

    $scope.onInserted = (publisher, publisherIndex, columnIndex) ->
      $scope.history.set publisher.id, 'to',
        publisher: publisherIndex
        column: columnIndex

    $scope.onDrop = (publisher, newStage) ->
      if publisher.publisher_stage_id is newStage.id then return
      publisher.publisher_stage_id = newStage.id
      if !newStage.open && newStage.probability == 0
#        $scope.showClosePublisherModal(publisher)
      else
        if $scope.history[publisher.id] && $scope.history[publisher.id].locked
          return publisher
        Publisher.update(id: publisher.id, publisher: publisher).then (publisher) ->
          $scope.history.lock(publisher.id, false)
        , (err) ->
          if err && err.data && err.data.errors && Object.keys(err.data.errors).length
            errors = err.data.errors
            errorsStack = []
            for key, error of errors
              errorsStack.push error
          else if err && err.statusText
            errorsStack = [err.statusText]
          if errorsStack.length
            $scope.undoLastMove(publisher.id)
#            $timeout ->
#              $scope.showPublisherErrors(publisher.id, errorsStack)
      publisher

    $scope.undoLastMove = (publisherId) ->
      last = $scope.history.get(publisherId)
      if last.from && last.to && last.from.column != last.to.column
        columnTo = $scope.publishersPipeline[last.to.column].publishers
        publisher = angular.copy _.findWhere columnTo, id: publisherId
        prevStage = $scope.stages[last.from.column]
        if publisher && prevStage
          publisher.publisher_stage_id = prevStage.id
          columnTo.splice(_.findIndex(columnTo, id: publisherId), 1)
          $scope.publishersPipeline[last.from.column].publishers.splice(last.from.publisher, 0, publisher)
          $scope.history.lock(publisherId, false)

    addScrollEvent = ->
      table = angular.element('.publishers-table')
      headers = angular.element('.column-header')
      headers.each (i) -> angular.element(this).css 'zIndex', headers.length - i
      offsetTop = table.offset().top
      $document.unbind 'scroll'
      $document.bind 'scroll', ->
        if $document.scrollTop() > offsetTop
          table.addClass 'fixed'
          headers.css 'top', $document.scrollTop() - offsetTop + 'px'
        else
          table.removeClass 'fixed'
          headers.css 'top', 0
      $scope.$on '$destroy', ->
        $document.unbind 'scroll'

#    createRandomPublisher = (name) ->
#      random = (min, max) -> Math.round(Math.random()*(max-min)) + min
#      accounts = [15880, 16302, 810, 753, 6337, 19811]
#      {
#        publisher:
#          comscore: Boolean(random(0, 1))
#          name: name
#          type_id: $scope.publisher_types[random(0, $scope.publisher_types.length - 1)].id
#          publisher_stage_id: $scope.publisher_stages[random(0, $scope.publisher_stages.length - 1)].id
#          client_id: accounts[random(0, accounts.length - 1)]
#          estimated_monthly_impressions: random(1, 10)
#      }
#    setTimeout ->
#      [1..500].map (i) -> Publisher.create(createRandomPublisher('Publisher ' + ('00' + i).slice(-3)))
#    , 3000

]
