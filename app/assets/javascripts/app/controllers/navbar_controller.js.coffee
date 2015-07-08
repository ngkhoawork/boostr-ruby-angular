@app.controller 'NavbarController', ['$scope', '$location', ($scope, $location) ->

  $scope.isActive = (viewLocation) ->
    viewLocation == $location.path()
  ]