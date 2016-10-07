@directives.directive 'startingPage', ['$location', '$http', 'CurrentUser',($location, $http, CurrentUser) ->
  restrict: 'E'
  templateUrl: 'directives/starting-page.html'
  controller: ($scope) ->
    $scope.userInfo = {}
    if(!$scope.current_user)
      CurrentUser.get().$promise.then (user) ->
        $scope.current_user = user
        if(user && user.starting_page == $location.$$url)
          $scope.userInfo.isUserStartingPage = true
    $scope.$on '$routeChangeStart', ->
      if($scope.current_user && $scope.current_user.starting_page == $location.$$url)
        $scope.userInfo.isUserStartingPage = true
      else
        $scope.userInfo.isUserStartingPage = false
      return
    $scope.setStartPage = () ->
      $scope.userInfo.isUserStartingPage = true
      $http.post('/api/users/starting_page', user: starting_page: $location.$$url).success (user) ->
        $scope.current_user = user
        return
 ]
