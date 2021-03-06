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
  'boostrServerErrors'
  'bgf.paginateAnything'
  'LocalStorageModule'
  'zFilterModule'
  'ngTextTruncate'
  'mdMarkdownIt'
])

@app.config (['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  
  adminGuard = ($rootScope, $location) ->
    unless $rootScope.currentUserRoles.isAdmin()
      alert("You don't have access here")
      $location.path('/')
      
  $routeProvider
    .when '/search',
      templateUrl: 'search.html'
      controller: 'SearchController'
      
    .when '/dashboard',
      templateUrl: 'dashboard.html'
      controller: 'DashboardController'

    .when '/deals/:id',
      templateUrl: 'deal.html'
      controller: 'DealController'

    .when '/deals',
      templateUrl: 'deals.html'
      controller: 'DealsController'

    .when '/accounts',
      templateUrl: 'accounts.html'
      controller: 'AccountsController'

    .when '/accounts/:id',
      templateUrl: 'account.html'
      controller: 'AccountController'

    .when '/contacts/:id',
      templateUrl: 'contact.html'
      controller: 'ContactController'

    .when '/contacts',
      templateUrl: 'contacts.html'
      controller: 'ContactsController'

    .when '/influencers',
      templateUrl: 'influencers.html'
      controller: 'InfluencersController'

    .when '/influencers/:id',
      templateUrl: 'influencer.html'
      controller: 'InfluencerController'

    .when '/old_revenue',
      templateUrl: 'old_revenue.html'
      controller: 'OldRevenueController'

    .when '/revenue',
      templateUrl: 'revenue.html'
      controller: 'RevenueController'
      reloadOnSearch: false

    .when '/revenue/ios/:id',
      templateUrl: 'io.html'
      controller: 'IOController'

    .when '/revenue/pmps/:id',
      templateUrl: 'pmp.html'
      controller: 'PMPController'

    .when '/activities',
      templateUrl: 'activities.html'
      controller: 'ActivitiesController'

    .when '/activity_types',
      templateUrl: 'activity_types.html'
      controller: 'ActivityTypesController'

    .when '/finance/billing',
      templateUrl: 'billing.html'
      controller: 'BillingController'

    .when '/reports/activity_summary',
      templateUrl: 'reports.html'
      controller: 'ReportsController'
      reloadOnSearch: false

    .when '/reports/pipeline_split_report',
      templateUrl: 'pipeline_split_report.html'
      controller: 'PipelineSplitReportController'
      reloadOnSearch: false

    .when '/reports/old_forecasts',
      templateUrl: 'old_forecasts_detail.html'
      controller: 'OldForecastsDetailController'

    .when '/reports/forecasts',
      templateUrl: 'forecasts_detail.html'
      controller: 'ForecastsDetailController'

    .when '/reports/old_product_forecasts',
      templateUrl: 'old_product_forecasts_detail.html'
      controller: 'OldProductForecastsDetailController'

    .when '/reports/product_forecasts',
      templateUrl: 'product_forecasts_detail.html'
      controller: 'ProductForecastsDetailController'

    .when '/reports/product_monthly_summary',
      templateUrl: 'product_monthly_summary.html'
      controller: 'ProductMonthlySummaryController'

    .when '/reports/spend_by_category',
      templateUrl: 'spend_by_category.html'
      controller: 'SpendByCategoryController'

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

    .when '/smart_reports/pacing_dashboard',
      templateUrl: 'pacing_dashboard.html'
      controller: 'PacingDashboardController'

    .when '/smart_reports/agency360',
      templateUrl: 'agency360.html'
      controller: 'Agency360Controller'

    .when '/reports/deal_reports',
      templateUrl: 'deal_reports.html'
      controller: 'DealReportsController'

    .when '/reports/pipeline_monthly_report',
      templateUrl: 'pipeline_monthly_report.html'
      controller: 'PipelineMonthlyReportController'

    .when '/reports/pipeline_changes_report',
      templateUrl: 'pipeline_changes_report.html'
      controller: 'PipelineChangeReportController'

    .when '/reports/pipeline_summary_report',
      templateUrl: 'pipeline_summary_report.html'
      controller: 'PipelineSummaryReportController'

    .when '/reports/pipeline_summary_reports',
      templateUrl: 'pipeline_summary_reports.html'
      controller: 'PipelineSummaryReportsController'
      
    .when '/reports/spend_by_account',
      templateUrl: 'spend_by_account.html'
      controller: 'SpendByAccountController'

    .when '/reports/publishers',
      templateUrl: 'publishers_report.html'
      controller: 'PublishersReportController'

    .when '/reports/activity_detail_reports',
      templateUrl: 'activity_detail_reports.html'
      controller: 'ActivityDetailReportsController'
      reloadOnSearch: false
      resolve:
        $modalInstance: -> null
        activitySummaryParams: -> null

    .when '/reports/influencer_budget_detail',
      templateUrl: 'influencer_budget_detail.html'
      controller: 'InfluencerBudgetDetailController'

    .when '/reports/quota_attainment',
      templateUrl: 'quota_attainment_report.html'
      controller: 'QuotaAttainmentReportController'

    .when '/requests',
      templateUrl: 'requests.html'
      controller: 'RequestsController'

    .when '/requests/:id',
      templateUrl: 'request.html'
      controller: 'RequestController'

    .when '/settings/',
      templateUrl: 'settings.html'
      controller: 'SettingsController'
      resolve: check: adminGuard

    .when '/settings/general',
      templateUrl: 'settings/general.html'
      controller: 'SettingsGeneralController'
      resolve: check: adminGuard

    .when '/settings/api_configurations',
      templateUrl: 'settings/api_configurations.html'
      controller: 'ApiConfigurationsController'
      resolve: check: adminGuard

    .when '/settings/integration_logs',
      templateUrl: 'settings/integration_logs.html'
      controller: 'IntegrationLogsController'
      resolve: check: adminGuard

    .when '/settings/integration_logs/:id',
      templateUrl: 'settings/integration_log.html'
      controller: 'IntegrationLogsController'
      resolve: check: adminGuard

    .when '/settings/io_feed_logs',
      templateUrl: 'settings/io_feed_logs.html'
      controller: 'CsvImportLogsController'
      resolve: check: adminGuard

    .when '/settings/smart_insights',
      templateUrl: 'settings/smart_insights.html'
      controller: 'SettingsSmartInsightsController'
      resolve: check: adminGuard

    .when '/settings/users',
      templateUrl: 'settings/users.html'
      controller: 'SettingsUsersController'
      resolve: check: adminGuard

    .when '/settings/currencies',
      templateUrl: 'settings/currencies.html'
      controller: 'SettingsCurrenciesController'
      resolve: check: adminGuard

    .when '/settings/data_import',
      templateUrl: 'settings/data_import_export.html'
      controller: 'DataImportExportController'
      resolve: check: adminGuard

    .when '/settings/notifications',
      templateUrl: 'settings/notifications.html'
      controller: 'SettingsNotificationsController'
      resolve: check: adminGuard

    .when '/settings/initiatives',
      templateUrl: 'settings/initiatives.html'
      controller: 'SettingsInitiativesController'
      resolve: check: adminGuard

    .when '/settings/products',
      templateUrl: 'settings/products.html'
      controller: 'SettingsProductsController'
      resolve: check: adminGuard

    .when '/settings/products/:id',
      templateUrl: 'settings/products.html'
      controller: 'SettingsProductsController'
      resolve: check: adminGuard

    .when '/settings/teams',
      templateUrl: 'settings/teams.html'
      controller: 'SettingsTeamsController'
      resolve: check: adminGuard

    .when '/settings/teams/:id',
      templateUrl: 'settings/team.html'
      controller: 'SettingsTeamController'
      resolve: check: adminGuard

    .when '/settings/custom_values',
      templateUrl: 'settings/custom_values.html'
      controller: 'SettingsCustomValuesController'
      resolve: check: adminGuard

    .when '/settings/time_periods',
      templateUrl: 'settings/time_periods.html'
      controller: 'SettingsTimePeriodsController'
      resolve: check: adminGuard

    .when '/settings/quotas/:time_period_id?',
      templateUrl: 'settings/quotas.html'
      controller: 'SettingsQuotasController'
      resolve: check: adminGuard

    .when '/settings/stages',
      templateUrl: 'settings/stages/main_stages.html'
      controller: 'MainStageController'
      resolve: check: adminGuard

    .when '/settings/workflows/',
      templateUrl: 'settings/workflows.html',
      controller: 'SettingsWorkflowsController'
      resolve: check: adminGuard

    .when '/settings/bps',
      templateUrl: 'settings/bps.html'
      controller: 'BPsController'
      resolve: check: adminGuard

    .when '/settings/bps/:id',
      templateUrl: 'settings/bp.html'
      controller: 'BPsBPController'
      resolve: check: adminGuard

    .when '/settings/custom_fields/',
      templateUrl: 'settings/custom_fields.html'
      controller: 'SettingsDealCustomFieldNamesController'
      resolve: check: adminGuard

    .when '/settings/ealerts/',
      templateUrl: 'settings/ealerts.html'
      controller: 'SettingsEalertsController'
      resolve: check: adminGuard

    .when '/settings/activity_types/',
      templateUrl: 'settings/activity_types.html'
      controller: 'SettingsActivityTypesController'
      resolve: check: adminGuard

    .when '/settings/permissions/',
      templateUrl: 'settings/permissions.html'
      controller: 'SettingsPermissionsController'
      resolve: check: adminGuard

    .when '/settings/validations/',
      templateUrl: 'settings/validations.html'
      controller: 'SettingsValidationsController'
      resolve: check: adminGuard

    .when '/settings/egnyte',
      templateUrl: 'settings/egnyte.html'
      controller: 'SettingsEgnyteController'
      resolve: check: adminGuard

    .when '/bps',
      templateUrl: 'bp.html'
      controller: 'BPController'

    .when '/agreements',
      templateUrl: 'agreements.html'
      controller: 'AgreementsController'
      
    .when '/agreements/:id',
      templateUrl: 'agreement.html'
      controller: 'AgreementController'

    .when '/forecast/:team_id?',
      templateUrl: 'forecasts.html'
      controller: 'ForecastsController'

    .when '/fore_cast_old/:team_id?',
      templateUrl: 'forecasts_old.html'
      controller: 'ForecastsOldController'

    .when '/users/sign_out',
      templateUrl: 'sign_out.html'
      controller: 'signOutController'

    .when '/publishers',
      templateUrl: 'publishers/publishers.html'
      controller: 'PablishersController'

    .when '/api/gmail_extension/',
      templateUrl: 'blank.html'
      controller: 'GmailExtensionController'

    .when '/api/calendar_extension/',
      templateUrl: 'blank.html'
      controller: 'CalendarExtensionController'

    .when '/publishers/:id',
      templateUrl: 'publishers/publisher.html'
      controller: 'PablisherController'

    .when '/leads',
      templateUrl: 'leads.html'
      controller: 'LeadsController'
      reloadOnSearch: false

    .when '/settings/leads',
      templateUrl: 'settings/leads.html'
      controller: 'LeadsSettingsController'
      resolve: check: adminGuard

    .when '/api_reference',
      templateUrl: 'api_reference.html'
      controller: 'ApiReferenceController'

    .when '/analytics',
      templateUrl: 'logi.html'
      controller: 'LogiConfigurationsController'

    .when '/profile',
      templateUrl: 'users/profile.html'
      controller: 'ProfileController'

    .when '/contracts',
      templateUrl: 'contracts/contracts.html'
      controller: 'ContractsController'

    .when '/contracts/:id',
      templateUrl: 'contracts/contract.html'
      controller: 'ContractController'

    .otherwise({ redirectTo: '/dashboard' })
  $locationProvider.html5Mode true
])

@app.config ['localStorageServiceProvider', (lssp) ->
  lssp.setPrefix 'bstr'
]

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

@app.config ['$compileProvider', ($compileProvider) ->
  $compileProvider.debugInfoEnabled false
]

@app.run ['editableOptions', (editableOptions) ->
  editableOptions.theme = 'bs3'
  editableOptions.buttons = 'no'
  editableOptions.activate = 'select'
  editableOptions.blurElem = 'submit'
  editableOptions.blurForm = 'cancel'
]

@app.run ['$rootScope', 'CurrentUser', ($rootScope, CurrentUser) ->
  $rootScope.currentUserIsLeader = currentUserIsLeader
  $rootScope.transloaditTemplates = transloaditTemplates
  $rootScope.userType = userType
  $rootScope.currentUserRoles = currentUserRoles

  if window.companyEgnyteSettings
    $rootScope.companyEgnyteEnabled = window.companyEgnyteSettings.enabled

  currentUserRoles.isAdmin = -> _.contains this, 'admin'
  currentUserRoles.isSuperAdmin = -> _.contains this, 'superadmin'

  CurrentUser.get().$promise.then (user) ->
    user.leader = user.is_leader
    $rootScope.currentUser = user
    updateTalkus user

  $rootScope.$on '$routeChangeSuccess', (scope, next, current) ->
    if $rootScope.currentUser then updateTalkus($rootScope.currentUser)

  updateTalkus = (user) ->
    if location.hostname is 'localhost' or
        location.hostname is '127.0.0.1' or
        location.pathname.indexOf('/api/gmail_extension/') is 0 or
        location.pathname.indexOf('/api/calendar_extension/') is 0
      return
    talkus('init', 'qu346HQax2ut3MQr4',
      id: user.id
      name: user.name
      email: user.email
    )
]
window._fixedHeaderHeight = 0 #updating in NavbarController

@service = angular.module 'services', ['ngResource']
@directives = angular.module 'directives', []
@filters = angular.module 'filters', []