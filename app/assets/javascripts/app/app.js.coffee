@app = angular.module('Boostr', [
  'services'
  'directives'
  'filters'
  'ngRoute'
  'templates'
  'ui.bootstrap'
  'ui.select'
  'ngSanitize'
  'ngFileUpload'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider
    .when '/dashboard',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'
    .when '/deals/:id',
      templateUrl: 'deal.html'
      controller: 'DealController'
    .when '/deals',
      templateUrl: 'deals.html'
      controller: 'DealsController'
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
    .when '/revenue',
      templateUrl: 'revenue.html'
      controller: 'RevenueController'
    .when '/settings/users',
      templateUrl: 'settings_users.html'
      controller: 'SettingsUsersController'
    .when '/settings/products',
      templateUrl: 'settings/products.html'
      controller: 'SettingsProductsController'
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

@app.config ['datepickerConfig', 'datepickerPopupConfig', (datepickerConfig, datepickerPopupConfig) ->
  datepickerConfig.showWeeks = false
  datepickerPopupConfig.showButtonBar = false
]

@service = angular.module 'services', ['ngResource']
@directives = angular.module 'directives', []
@filters = angular.module 'filters', []
