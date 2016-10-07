@directives.directive 'startingPage', ['$location', '$http', ($location, $http) ->
  restrict: 'E'
  templateUrl: 'directives/starting-page.html'
  controller: ($scope) ->
    $scope.setStartPage = () ->
      $http.post '/api/users/starting_page', user:
        starting_page: $location.$$url
 ]
