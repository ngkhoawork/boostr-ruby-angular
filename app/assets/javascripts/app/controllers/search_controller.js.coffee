@app.controller 'SearchController',
['$scope', '$location', '$timeout', 'Search',
( $scope,   $location,   $timeout,   Search) ->
    $scope.query = $location.search().query
    $scope.clients = []
    $scope.contacts = []
    $scope.deals = []
    $scope.ios = []
    $scope.isLoading = false
    $scope.allLoaded = false
    $scope.page = 1

    getData = () ->
      if $scope.query.length > 0
        Search.all(query: $scope.query, page: $scope.page).then (results) ->
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
          $scope.allLoaded = !results.length
          $timeout -> $scope.isLoading = false

    $scope.loadMore = ->
        $scope.page++
        $scope.isLoading = true
        getData()

    getData()
]
