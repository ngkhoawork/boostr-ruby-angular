@app = angular.module('Boostr', [
  'ngRoute'
  'templates'
  'ui.bootstrap'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/dashboard',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'
    .when '/clients',
      templateUrl: 'clients.html'
      controller: 'ClientsController'
    .when '/people',
      templateUrl: 'people.html'
      controller: 'PeopleController'
    .otherwise({ redirectTo: '/dashboard' })
  $locationProvider.html5Mode true
])