@app.controller 'PablishersController', [
  '$scope', '$q', '$document', '$timeout', '$modal', 'Publisher', 'PublishersFilter', 'localStorageService'
  ($scope,   $q,   $document,   $timeout,   $modal,   Publisher,   PublishersFilter,   localStorageService) ->

    $scope.baseColor = '#81B130'
    $scope.publishers = []
    $scope.publishersPipeline = []
    $scope.view = localStorageService.get('publishersViewType') || 'list'
    page = 1
    per = 10
    $scope.isPublishersLoading = false
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
      $scope.isPublishersLoading = false
      $scope.allPublishersLoaded = false

    $scope.changeView = (view) ->
      $scope.view = view
      localStorageService.set('publishersViewType', view)
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
        $scope.renewal_term_fields = $scope.filter.renewal_term_fields = settings.renewal_term_fields

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

    setLoading = (bool, err) ->
      if bool then $scope.isPublishersLoading = bool else $timeout -> $scope.isPublishersLoading = bool
      if err
        $scope.allPublishersLoaded = true
        console.log err

    getPublishersList = (params) ->
      setLoading(true)
      Publisher.publishersList(params).then (publishers) ->
        $scope.allPublishersLoaded = !publishers || publishers.length < per
        if page++ > 1
          $scope.publishers = $scope.publishers.concat(publishers)
        else
          $scope.publishers = publishers
        setLoading(false)
      , (err) ->
        setLoading(false, err)

    getPublishersPipeline = (params) ->
      setLoading(true)
      if page is 1
        $q.all(
          headers: Publisher.pipelineHeaders(_.omit params, ['per', 'page'])
          pipeline: Publisher.publishersPipeline(params)
        ).then (data) ->
          $scope.publishersPipeline = _.map data.headers, (stage) ->
            _.extend stage, _.findWhere data.pipeline, id: stage.id
          page++
          $timeout -> addScrollEvent()
          setLoading(false)
        , (err) ->
          setLoading(false, err)
      else
        Publisher.publishersPipeline(params).then (pipeline) ->
          $scope.allPublishersLoaded = !pipeline || _.every pipeline, (stage) -> stage.publishers.length < per
          $scope.publishersPipeline = _.map $scope.publishersPipeline, (stage, i) ->
            stagePipeline = _.findWhere pipeline, id: stage.id
            stage.publishers = [].concat stage.publishers, (stagePipeline && stagePipeline.publishers) || []
            stage
          page++
          setLoading(false)
        , (err) ->
          setLoading(false, err)

    $scope.loadMorePublishers = ->
      $scope.getPublishers(true)

    $scope.updatePublisher = (publisher) ->
      params = {
        comscore: publisher.comscore
      }

      if publisher.renewal_term
        params.renewal_term_id = publisher.renewal_term.id

      if publisher.type
        params.type_id = publisher.type.id

      if publisher.publisher_stage
        params.publisher_stage_id = publisher.publisher_stage.id

      Publisher.update(id: publisher.id, publisher: params)


    $scope.showNewPublisherModal = ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_form.html'
        size: 'md'
        controller: 'PablisherActionsController'
        backdrop: 'static'
        keyboard: false
        resolve:
          publisher: ->
            {}

    $scope.$on 'updated_publishers', ->
      $scope.init()

    $scope.init()

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

    $scope.$on 'updated_publishers', ->
      if $scope.view != 'columns' then return;
      params = getParams()
      Publisher.pipelineHeaders(_.omit params, ['per', 'page']).then (headers) ->
        $scope.publishersPipeline = _.map $scope.publishersPipeline, (stage) ->
          stageHeader = _.findWhere headers, id: stage.id
          stage.publishers_count = stageHeader.publishers_count if stageHeader
          stage

]
