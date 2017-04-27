@app.controller 'NavbarController', ['$scope', '$location', ($scope, $location) ->

    $scope.isActive = (viewLocation) ->
      $location.path().indexOf(viewLocation) == 0

]