@app.controller 'PablishersController',
  ['$scope', 'Publisher', '$modal', ( $scope, Publisher, $modal ) ->
    $scope.publishers = []
    $scope.publisherTypes = [
      {name: 'All'}
      {name: 'My Publishers', my_publishers_bool: true}
      {name: 'My Team\'s publishers', my_team_publishers_bool: true}
    ]

    $scope.init = ->
      $scope.teamFilter = $scope.publisherTypes[0]
      $scope.getPublishers()
      $scope.getPublisherSettings()

    $scope.filterPublishers = (type) ->
      $scope.teamFilter = type
      $scope.getPublishers()

    $scope.getPublisherSettings = () ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_types = settings.publisher_types
        $scope.publisher_stages = settings.publisher_stages

    $scope.getPublishers = ->
      param = $scope.teamFilter
      param.q = $scope.searchText

      Publisher.publishersList($scope.teamFilter).then (publishers) ->
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