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
  'daterangepicker'
  'rzModule'
  'monospaced.elastic'
  'dndLists'
  'jsonFormatter'
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
    .when '/old_revenue',
      templateUrl: 'old_revenue.html'
      controller: 'OldRevenueController'
    .when '/revenue',
      templateUrl: 'revenue.html'
      controller: 'RevenueController'
    .when '/ios/:id',
      templateUrl: 'io.html'
      controller: 'IOController'
    .when '/activities',
      templateUrl: 'activities.html'
      controller: 'ActivitiesController'
    .when '/activity_types',
      templateUrl: 'activity_types.html'
      controller: 'ActivityTypesController'
    .when '/reports/activity_summary',
      templateUrl: 'reports.html'
      controller: 'ReportsController'
    .when '/reports/forecasts',
      templateUrl: 'forecasts_detail.html'
      controller: 'ForecastsDetailController'
    .when '/smart_reports/sales_execution_dashboard',
      templateUrl: 'sales_execution_dashboard.html'
      controller: 'SalesExecutionDashboardController'
    .when '/smart_reports/kpi_analytics',
      templateUrl: 'kpi_analytics.html'
      controller: 'KPIAnalyticsController'
    .when '/smart_reports/monthly_forecasts',
      templateUrl: 'monthly_forecasts.html'
      controller: 'MonthlyForecastsController'
    .when '/smart_reports/where_to_pitch',
      templateUrl: 'where_to_pitch.html'
      controller: 'WhereToPitchController'
    .when '/smart_reports/inactives',
      templateUrl: 'inactives.html'
      controller: 'InactivesController'
    .when '/smart_reports/initiatives',
      templateUrl: 'initiatives_summary.html'
      controller: 'InitiativesSummaryController'
    .when '/reports/deal_reports',
      templateUrl: 'deal_reports.html'
      controller: 'DealReportsController'
    .when '/reports/pipeline_changes_report',
      templateUrl: 'pipeline_changes_report.html'
      controller: 'PipelineChangeReportController'
    .when '/reports/pipeline_summary_reports',
      templateUrl: 'pipeline_summary_reports.html'
      controller: 'PipelineSummaryReportsController'
    .when '/reports/activity_detail_reports',
      templateUrl: 'activity_detail_reports.html'
      controller: 'ActivityDetailReportsController'
    .when '/settings/general',
      templateUrl: 'settings/general.html'
      controller: 'SettingsGeneralController'
    .when '/settings/api_configurations',
      templateUrl: 'settings/api_configurations.html'
      controller: 'ApiConfigurationsController'
    .when '/settings/integration_logs',
      templateUrl: 'settings/integration_logs.html'
      controller: 'IntegrationLogsController'
    .when '/settings/integration_logs/:id',
      templateUrl: 'settings/integration_log.html'
      controller: 'IntegrationLogsController'
    .when '/settings/io_feed_logs',
      templateUrl: 'settings/io_feed_logs.html'
      controller: 'CsvImportLogsController'
    .when '/settings/smart_insights',
      templateUrl: 'settings/smart_insights.html'
      controller: 'SettingsSmartInsightsController'
    .when '/settings/users',
      templateUrl: 'settings/users.html'
      controller: 'SettingsUsersController'
    .when '/settings/currencies',
      templateUrl: 'settings/currencies.html'
      controller: 'SettingsCurrenciesController'
    .when '/settings/data_import',
      templateUrl: 'settings/data_import_export.html'
      controller: 'DataImportExportController'
    .when '/settings/notifications',
      templateUrl: 'settings/notifications.html'
      controller: 'SettingsNotificationsController'
    .when '/settings/initiatives',
      templateUrl: 'settings/initiatives.html'
      controller: 'SettingsInitiativesController'
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
    .when '/settings/bps',
      templateUrl: 'settings/bps.html'
      controller: 'BPsController'
    .when '/settings/bps/:id',
      templateUrl: 'settings/bp.html'
      controller: 'BPsBPController'
    .when '/settings/custom_fields/',
      templateUrl: 'settings/custom_fields.html'
      controller: 'SettingsDealCustomFieldNamesController'
    .when '/bp',
      templateUrl: 'bp.html'
      controller: 'BPController'
    .when '/forecast/:team_id?',
      templateUrl: 'forecasts.html'
      controller: 'ForecastsController'
    .when '/users/sign_out',
      templateUrl: 'sign_out.html'
      controller: 'signOutController'
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
  editableOptions.activate = 'select'
  editableOptions.blurElem = 'submit'
  editableOptions.blurForm = 'cancel'
]

@app.run ['$rootScope', ($rootScope) ->
  $rootScope.currentUserIsLeader = currentUserIsLeader
  $rootScope.transloaditTemplate = transloaditTemplate
  $rootScope.userType = userType
]

@app.run ['$rootScope', 'CurrentUser', ($rootScope, CU) ->
  $rootScope.$on '$routeChangeSuccess', (scope, next, current) ->
    if $rootScope.currentUser
      updateTalkus($rootScope.currentUser)
    else
      CU.get().$promise.then (user) ->
        $rootScope.currentUser = user
        updateTalkus(user)

  updateTalkus = (user) ->
    talkus('init', 'qu346HQax2ut3MQr4',
      id: user.id
      name: user.name
      email: user.email
    )
]

@service = angular.module 'services', ['ngResource']
@directives = angular.module 'directives', []
@filters = angular.module 'filters', []
