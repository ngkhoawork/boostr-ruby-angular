@directives.directive 'startingPage', ['$rootScope', '$location', '$http', ($rootScope, $location, $http) ->
  restrict: 'E'
  templateUrl: 'directives/starting-page.html'
  controller: ($scope) ->
    $scope.userInfo = {}

    if(!$scope.currentUser)
      $rootScope.$watch 'currentUser', (user) ->
        if user
          $scope.currentUser = user
          if(user.starting_page == $location.$$url)
            $scope.userInfo.isUserStartingPage = true

    $scope.$on '$routeChangeStart', ->
      if($scope.currentUser && $scope.currentUser.starting_page == $location.$$url)
        $scope.userInfo.isUserStartingPage = true
      else
        $scope.userInfo.isUserStartingPage = false
      return

    $scope.setStartPage = () ->
      if($scope.userInfo && $scope.userInfo.isUserStartingPage)
        return
      $scope.userInfo.isUserStartingPage = true
      $http.post('/api/users/starting_page', user: starting_page: $location.$$url).success (user) ->
        $scope.currentUser = user
        return

    $scope.extensionUrl = (id) ->
      if id == 'gmail'
        _gmail_extension_url
      else if id == 'gcalendar'
        _gcalendar_extension_url

    $scope.isExtensionEnabled = (id) ->
      if id == 'gmail'
        _isGmailExtensionEnabled && _gmail_extension_url
      else if id == 'gcalendar'
        _isGcalendarExtensionEnabled && _gcalendar_extension_url
 ]
