@app.controller 'InfluencersController',
  ['$scope', '$rootScope', '$timeout', '$window', '$modal', '$location', '$sce', '$httpParamSerializer', 'Field', 'Influencer'
  ( $scope,   $rootScope, $timeout,  $window,   $modal,   $location,   $sce,   $httpParamSerializer,   Field,   Influencer) ->
      $scope.scrollCallback = -> $timeout -> $scope.$emit 'lazy:scroll'
      $scope.influencers = []
      $scope.feedName = 'Updates'
      $scope.page = 1
      $scope.query = ""
      $scope.showMeridian = true
      $scope.types = []
      $scope.errors = {}
      $scope.itemType = 'Contact'

      $scope.init = ->
        $scope.getInfluencers()
        Field.defaults({}, 'Influencer').then (fields) ->
          network_types = Field.findNetworkTypes(fields)
          $scope.setNetworkTypes(network_types)

      $scope.setNetworkTypes = (network_types) ->
        $scope.network_types = network_types
        network_types.options.forEach (option) ->
          $scope[option.name] = option.id


      $scope.$watch 'query', (oldValue, newValue) ->
        if oldValue != newValue
          $scope.page = 1
          $scope.getInfluencers($scope.scrollCallback)

      $scope.getInfluencers = (callback) ->
        $scope.isLoading = true
        params = {
          page: $scope.page,
          per: 10
        }
        if $scope.query.trim().length
          params.name = $scope.query.trim()
        Influencer.all(params).then (influencers) ->
          if $scope.page > 1
            $scope.influencers = $scope.influencers.concat(influencers)
          else
            $scope.influencers = influencers
          $scope.isLoading = false
          callback() if _.isFunction callback

      $scope.isLoading = false

      $scope.loadMoreInfluencers = ->
        if $scope.influencers && $scope.influencers.length < Influencer.resource.totalCount
          $scope.page = $scope.page + 1
          $scope.getInfluencers()

      $scope.concatAddress = (address) ->
        row = []
        if address
          if address.city then row.push address.city
          if address.state then row.push address.state
          if address.zip then row.push address.zip
          if address.country then row.push address.country
        row.join(', ')

      $scope.showModal = ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/influencer_form.html'
          size: 'md'
          controller: 'InfluencersNewController'
          backdrop: 'static'
          keyboard: false
          resolve:
            influencer: ->
              {}

      $scope.showEditModal = ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/influencer_form.html'
          size: 'md'
          controller: 'InfluencersEditController'
          backdrop: 'static'
          keyboard: false
          resolve:
            influencer: ->
              undefined

      $scope.export = ->
        params = {
          filter: $scope.teamFilter().param,
        }
        params = _.extend params, $scope.filter.get()
        if $scope.query.trim().length
          params.name = $scope.query.trim()
        $window.open Contact.exportUrl + '?' + $httpParamSerializer params
        return

      $scope.$on 'updated_influencers', ->
        $scope.init()

      $scope.$on 'newInfluencer', (event, influencer) ->
        $location.path('/influencers/' + influencer.id)

      $scope.init()

  ]
