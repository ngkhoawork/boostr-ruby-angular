@app.controller 'PMPController',
  ['$rootScope', '$scope', '$modal', '$filter', '$timeout', '$routeParams', '$location', '$q', 'PMP', 'PMPMember', 'SSP', 'ContentFee', 'User', 'CurrentUser', 'Product', 'DisplayLineItem', 'Company', 'InfluencerContentFee'
  ( $rootScope,   $scope,   $modal,   $filter,   $timeout,   $routeParams,   $location,   $q,   PMP,   PMPMember,   SSP,   ContentFee,   User,   CurrentUser,   Product,   DisplayLineItem,   Company,   InfluencerContentFee) ->
      $scope.currentPMP = {}
      $scope.currency_symbol = '$'
      $scope.canEditIO = true
      
      $scope.init = ->
        CurrentUser.get().$promise.then (user) ->
          $scope.currentUser = user
        # $scope.currentUser = $rootScope.currentUser
        console.log($rootScope.currentUser)
        Company.get().$promise.then (company) ->
          $scope.company = company
          $scope.canEditIO = $scope.company.io_permission[$scope.currentUser.user_type]
        SSP.all().then (ssps) ->
          console.log(ssps)
          $scope.ssps = ssps
        PMP.get($routeParams.id).then (pmp) ->
          $scope.currentPMP = pmp
          console.log('currentPMP', $scope.currentPMP);
          if pmp.currency
            if pmp.currency.curr_symbol
              $scope.currency_symbol = pmp.currency.curr_symbol
          PMP.pmp_item_daily_actuals($routeParams.id).then (data) ->
            $scope.pmpItemDailyActuals = data

          $scope.currency_symbol = (->
            if $scope.currentPMP && $scope.currentPMP.currency
              if $scope.currentPMP.currency.curr_symbol
                return $scope.currentPMP.currency.curr_symbol
              else if $scope.currentPMP.currency.curr_cd
                return $scope.currentPMP.currency.curr_cd
            return '%'
          )()

      $scope.deleteMember = (pmp_member) ->
        if confirm('Are you sure you want to delete "' + pmp_member.name + '"?')
          PMPMember.delete(id: pmp_member.id, pmp_id: $scope.currentPMP.id).then (pmp) ->
            $scope.currentPMP = pmp

      $scope.showLinkExistingUser = ->
        User.query().$promise.then (users) ->
          $scope.users = $filter('notIn')(users, $scope.currentPMP.pmp_members, 'user_id')

      $scope.linkExistingUser = (item) ->
        $scope.userToLink = undefined
        PMPMember.create(
          pmp_id: $scope.currentPMP.id,
          pmp_member: {
            user_id: item.id,
            share: 0,
            from_date: $scope.currentPMP.start_date,
            to_date: $scope.currentPMP.end_date,
            values: []
          }).then (pmp) ->
            $scope.currentPMP = pmp

      $scope.updatePMPMember = (data) ->
        PMPMember.update(id: data.id, pmp_id: $scope.currentPMP.id, pmp_member: data).then (pmp) ->
          $scope.currentPMP = pmp

      $scope.init()
  ]
