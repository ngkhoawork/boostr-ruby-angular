@app.controller 'ActivitiesController',
['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'Activity',
($scope, $rootScope, $modal, $routeParams, $location, $window, Activity) ->

  $scope.init = ->
    Activity.all().then (activities) ->
      $scope.activities = activities

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.init()
]
