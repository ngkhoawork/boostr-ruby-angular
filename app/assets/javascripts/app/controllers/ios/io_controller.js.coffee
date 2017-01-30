@app.controller 'IOController',
  ['$scope', '$modal', '$filter', '$routeParams', '$location', '$q', 'IO', 'IOMember', 'ContentFee', 'User', 'CurrentUser'
    ($scope, $modal, $filter, $routeParams, $location, $q, IO, IOMember, ContentFee, User, CurrentUser) ->
      $scope.currentIO = {}
      $scope.activeTab = 'ios'
      $scope.currency_symbol = '$'

      $scope.init = ->
        CurrentUser.get().$promise.then (user) ->
          $scope.currentUser = user
        IO.get($routeParams.id).then (io) ->
          $scope.currentIO = io
          if io.currency
            if io.currency.curr_symbol
              $scope.currency_symbol = io.currency.curr_symbol

      $scope.showLinkExistingUser = ->
        User.query().$promise.then (users) ->
          $scope.users = $filter('notIn')(users, $scope.currentIO.io_members, 'user_id')

      $scope.linkExistingUser = (item) ->
        $scope.userToLink = undefined
        IOMember.create(io_id: $scope.currentIO.id, io_member: { user_id: item.id, share: 0, from_date: $scope.currentIO.start_date, to_date: $scope.currentIO.end_date, values: [] }).then (io) ->
          $scope.currentIO = io

      $scope.setActiveTab = (type) ->
        $scope.activeTab = type

      $scope.isActiveTab = (type) ->
        return $scope.activeTab == type

      $scope.go = (path) ->
        $location.path(path)

      $scope.updateContentFee = (data) ->
        $scope.errors = {}
        ContentFee.update(id: data.id, io_id: $scope.currentIO.id, content_fee: data).then(
          (io) ->
            $scope.currentIO = io
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
        )
      $scope.updateIOMember = (data) ->
        IOMember.update(id: data.id, io_id: $scope.currentIO.id, io_member: data).then (io) ->
          $scope.currentIO = io

      $scope.deleteMember = (io_member) ->
        if confirm('Are you sure you want to delete "' +  io_member.name + '"?')
          IOMember.delete(id: io_member.id, io_id: $scope.currentIO.id).then (io) ->
            $scope.currentIO = io

      $scope.updateIO = ->
        $scope.errors = {}
        IO.update(id: $scope.currentIO.id, io: $scope.currentIO).then(
          (io) ->
            $scope.currentIO = io
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
        )
      $scope.init()
  ]
