@app = angular.module('Boostr', [
  'services'
  'directives'
  'filters'
  'ngRoute'
  'templates'
  'ui.bootstrap'
  'ui.select'
  'ngSanitize'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/dashboard',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'
    .when '/clients/:id',
      templateUrl: 'clients.html'
      controller: 'ClientsController'
    .when '/clients',
      templateUrl: 'clients.html'
      controller: 'ClientsController'
    .when '/people/:id',
      templateUrl: 'contacts.html'
      controller: 'ContactsController'
    .when '/people',
      templateUrl: 'contacts.html'
      controller: 'ContactsController'
    .otherwise({ redirectTo: '/dashboard' })
  $locationProvider.html5Mode true
])

@app.config ['$httpProvider', ($httpProvider) ->
  csrfToken = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = csrfToken
]

@app.config ['uiSelectConfig', (uiSelectConfig) ->
  uiSelectConfig.theme = 'bootstrap'
]

@service = angular.module 'services', ['ngResource']
@directives = angular.module 'directives', []
@filters = angular.module 'filters', []
