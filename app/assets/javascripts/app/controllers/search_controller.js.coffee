@app.controller 'SearchController',
['$scope', '$location', '$timeout', 'Search', '$q', '$modal', 'Activity',
( $scope,   $location,   $timeout,   Search,   $q,   $modal,   Activity) ->
    $scope.query = $location.search().query
    $scope.clients = []
    $scope.contacts = []
    $scope.deals = []
    $scope.ios = []
    $scope.activities = []
    $scope.isLoading = false
    $scope.allLoaded = false
    $scope.page = 1

    getData = () ->
      deferred = $q.defer()
      $scope.isLoading = true
      if $scope.query.length > 0
        Search.all(query: $scope.query, page: $scope.page).then (results) ->
          $scope.results = ($scope.results || []).concat results
          _.each results, (record) ->
            switch(record.searchable_type)
              when 'Client'
                $scope.clients.push record.details
              when 'Contact'
                $scope.contacts.push record.details
              when 'Deal'
                $scope.deals.push record.details
              when 'Io'
                $scope.ios.push record.details
              when 'Activity'
                $scope.activities.push record.details
          $scope.allLoaded = !results.length
          $timeout -> $scope.isLoading = false
          deferred.resolve()
      deferred.promise

    getCount = () ->
      Search.count(query: $scope.query).then (res) ->
        $scope.count = res.count

    $scope.loadMore = ->
      deferred = $q.defer()
      $scope.page++
      $scope.isLoading = true
      getData().then () -> deferred.resolve()
      deferred.promise

    getResultCount = (id) ->
      switch(id)
        when '#contacts-section' 
          $scope.contacts.length
        when '#deals-section' 
          $scope.deals.length
        when '#ios-section' 
          $scope.ios.length
        when '#activities-section'
          $scope.activities.length

    $scope.scrollTo = (id) ->
      if !$scope.allLoaded && id != '#accounts-section' && getResultCount(id) == 0
        $scope.loadMore().then () ->
          $scope.scrollTo(id)
      else
        $timeout(() ->
          return unless angular.element(id).offset()
          angular.element('html, body').animate {
            scrollTop: angular.element(id).offset().top - 100
          }, 1000
        ,0,false)

    $scope.showActivityEditModal = (activity) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/activity_new_form.html'
        size: 'md'
        controller: 'ActivityNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          activity: ->
            activity
          options: ->
            null

    $scope.deleteActivity = (activity) ->
      if confirm('Are you sure you want to delete the activity?')
        Activity.delete(activity).then () ->
          index = $scope.activities.indexOf(activity)
          $scope.activities.splice(index, 1)

    getCount()
    getData()
]
