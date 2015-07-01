@app = angular.module('Boostr', [
  'ngRoute'
  'templates'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'
    .otherwise({ redirectTo: '/' })
  $locationProvider.html5Mode true
])