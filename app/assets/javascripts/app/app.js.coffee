@app = angular.module('Boostr', [
  'services'
  'directives'
  'filters'
  'ngRoute'
  'ngMessages'
  'templates'
  'ui.bootstrap'
  'ui.select'
  'ngSanitize'
  'ngFileUpload'
  'xeditable'
  'tc.chartjs'
  'angular-loading-bar'
  'ui.sortable'
  'ngInflection'
  'timepickerPop'
  'infinite-scroll'
  'tree.dropdown'
  'd3'
  'nvd3'
  'ngTransloadit'
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
    .when '/contacts/:id',
      templateUrl: 'contacts.html'
      controller: 'ContactsController'
    .when '/contacts',
      templateUrl: 'contacts.html'
      controller: 'ContactsController'
    .when '/revenue',
      templateUrl: 'revenue.html'
      controller: 'RevenueController'
    .when '/activities',
      templateUrl: 'activities.html'
      controller: 'ActivitiesController'
    .when '/activity_types',
      templateUrl: 'activity_types.html'
      controller: 'ActivityTypesController'
    .when '/reports',
      templateUrl: 'reports.html'
      controller: 'ReportsController'
    .when '/reports/forecasts',
      templateUrl: 'forecasts_detail.html'
      controller: 'ForecastsDetailController'
    .when '/reports/sales_execution_dashboard',
      templateUrl: 'sales_execution_dashboard.html'
      controller: 'SalesExecutionDashboardController'
    .when '/reports/deal_reports',
      templateUrl: 'deal_reports.html'
      controller: 'DealReportsController'
    .when '/reports/pipeline_summary_reports',
      templateUrl: 'pipeline_summary_reports.html'
      controller: 'PipelineSummaryReportsController'
    .when '/settings/general',
      templateUrl: 'settings/general.html'
      controller: 'SettingsGeneralController'
    .when '/settings/smart_insights',
      templateUrl: 'settings/smart_insights.html'
      controller: 'SettingsSmartInsightsController'
    .when '/settings/users',
      templateUrl: 'settings/users.html'
      controller: 'SettingsUsersController'
    .when '/settings/tools',
      templateUrl: 'settings/tools.html'
      controller: 'SettingsToolsController'
    .when '/settings/notifications',
      templateUrl: 'settings/notifications.html'
      controller: 'SettingsNotificationsController'
    .when '/settings/products',
      templateUrl: 'settings/products.html'
      controller: 'SettingsProductsController'
    .when '/settings/teams',
      templateUrl: 'settings/teams.html'
      controller: 'SettingsTeamsController'
    .when '/settings/teams/:id',
      templateUrl: 'settings/team.html'
      controller: 'SettingsTeamController'
    .when '/settings/custom_values',
      templateUrl: 'settings/custom_values.html'
      controller: 'SettingsCustomValuesController'
    .when '/settings/time_periods',
      templateUrl: 'settings/time_periods.html'
      controller: 'SettingsTimePeriodsController'
    .when '/settings/quotas/:time_period_id?',
      templateUrl: 'settings/quotas.html'
      controller: 'SettingsQuotasController'
    .when '/settings/stages',
      templateUrl: 'settings/stages.html'
      controller: 'SettingsStagesController'
    .when '/forecast/:team_id?',
      templateUrl: 'forecasts.html'
      controller: 'ForecastsController'
    .otherwise({ redirectTo: '/dashboard' })
  $locationProvider.html5Mode true
])

@app.config ['$httpProvider', ($httpProvider) ->
  csrfToken = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.common['Accept'] = 'application/json'
]

@app.config ['uiSelectConfig', (uiSelectConfig) ->
  uiSelectConfig.theme = 'bootstrap'
]

@app.config ['datepickerConfig', 'datepickerPopupConfig', (datepickerConfig, datepickerPopupConfig) ->
  datepickerConfig.showWeeks = false
  datepickerPopupConfig.showButtonBar = false
]

@app.run ['editableOptions', (editableOptions) ->
  editableOptions.theme = 'bs3'
  editableOptions.buttons = 'no'
  editableOptions.blurElem = 'cancel'
  editableOptions.blurForm = 'cancel'
]

@app.run ['$rootScope', ($rootScope) ->
  $rootScope.currentUserIsLeader = currentUserIsLeader
]

@service = angular.module 'services', ['ngResource']
@directives = angular.module 'directives', []
@filters = angular.module 'filters', []
