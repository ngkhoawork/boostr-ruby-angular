@app = angular.module('Boostr', [
  'ngRoute'
  'templates'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/dashboard',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'
    .when '/clients',
      templateUrl: 'clients.html'
      controller: 'ClientsController'
    .otherwise({ redirectTo: '/dashboard' })
  $locationProvider.html5Mode true
])