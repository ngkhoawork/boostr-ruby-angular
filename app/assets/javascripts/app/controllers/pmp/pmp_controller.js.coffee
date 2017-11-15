@app.controller 'PMPController',
    ['$scope', '$modal', '$filter', '$timeout', '$routeParams', '$location', '$q', 'PMP', 'IOMember', 'ContentFee', 'User', 'CurrentUser', 'Product', 'DisplayLineItem', 'Company', 'InfluencerContentFee'
    ( $scope,   $modal,   $filter,   $timeout,   $routeParams,   $location,   $q,   PMP,   IOMember,   ContentFee,   User,   CurrentUser,   Product,   DisplayLineItem,   Company,   InfluencerContentFee) ->
            $scope.currentPMP = {}
            $scope.currency_symbol = '$'
            
            $scope.init = ->
                CurrentUser.get().$promise.then (user) ->
                    $scope.currentUser = user
                Company.get().$promise.then (company) ->
                    $scope.company = company
                    $scope.canEditIO = $scope.company.io_permission[$scope.currentUser.user_type]
                    console.log('$scope.canEditIO', $scope.canEditIO)
                PMP.get($routeParams.id).then (pmp) ->
                    $scope.currentPMP = pmp
                    if pmp.currency
                        if pmp.currency.curr_symbol
                            $scope.currency_symbol = pmp.currency.curr_symbol
                    
                    $scope.currency_symbol = (->
                        if $scope.currentPMP && $scope.currentPMP.currency
                            if $scope.currentPMP.currency.curr_symbol
                                return $scope.currentPMP.currency.curr_symbol
                            else if $scope.currentPMP.currency.curr_cd
                                return $scope.currentPMP.currency.curr_cd
                        return '%'
                    )()

            $scope.init()
    ]
