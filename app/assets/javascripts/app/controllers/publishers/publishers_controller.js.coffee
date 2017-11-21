@app.controller 'PablishersController',
  ['$scope', 'Publisher', ( $scope, Publisher ) ->
    $scope.publishers = []
    $scope.publisherTypes = [
      {name: 'All'}
      {name: 'My Publishers', my_publishers_bool: true}
      {name: 'My Team\'s publishers', my_team_publishers_bool: true}
    ]

    $scope.init = ->
      $scope.teamFilter = $scope.publisherTypes[0]
      $scope.getPublishers()

    $scope.filterPublishers = (type) ->
      $scope.teamFilter = type
      $scope.getPublishers()

    $scope.getPublishers = ->
      param = $scope.teamFilter
      param.q = $scope.searchText

      Publisher.publishersList($scope.teamFilter).then (publishers) ->
        $scope.publishers = publishers

    $scope.init()
  ]