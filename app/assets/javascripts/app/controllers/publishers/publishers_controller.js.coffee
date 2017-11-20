@app.controller 'PablishersController',
  ['$scope', 'Publisher', ( $scope, Publisher) ->
    console.log("2222222222222222222222222222222222222")
    $scope.publishers = []

    Publisher.publishersList().then (publishers) ->
      $scope.publishers = publishers
  ]