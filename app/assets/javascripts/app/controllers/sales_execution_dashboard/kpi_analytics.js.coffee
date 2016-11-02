@app.controller 'KPIAnalyticsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'User', 'ActivityType', 'TimePeriod', 'Company', 'ActivityReport',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, User, ActivityType, TimePeriod, Company, ActivityReport) ->

      $scope.teamFilters = [
        { name: 'My Team', param: '' }
        { name: 'All Team', param: 'all' }
      ]

      $scope.sellerFilters = [
        { name: 'seller1', param: 'seller1' }
        { name: 'seller2', param: 'seller2' }
      ]

      $scope.timeFilters = [
        { name: 'time1', param: 'time1' }
        { name: 'time2', param: 'time2' }
      ]

      $scope.productFilters = [
        { name: 'product1', param: 'product1' }
        { name: 'product2', param: 'product2' }
      ]

  ]
