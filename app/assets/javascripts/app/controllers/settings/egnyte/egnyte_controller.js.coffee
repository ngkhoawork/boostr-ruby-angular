@app.controller 'SettingsEgnyteController',
  ['$scope', '$modal', 'Egnyte', '$window', '$location', 'Company', ( $scope, $modal, Egnyte, $window, $location, Company) ->
    $scope.egnyte = {}
    $scope.currentEgnyteUser = {}

    currentParams = (aURL) ->
      aURL = aURL or window.location.href
      vars = {}
      hashes = aURL.slice(aURL.indexOf('#') + 1).split('&')
      i = 0
      while i < hashes.length
        hash = hashes[i].split('=')
        if hash.length > 1
          vars[hash[0]] = hash[1]
        else
          vars[hash[0]] = null
        i++
      vars

    $scope.init = () ->
      getToken()
      Company.get().$promise.then (company) ->
        $scope.company = company

    getToken = () ->
      params = currentParams()
      if params.access_token
        Egnyte.saveToken(params).then (response) ->
          $location.url($location.path());

    $scope.updateEgnyte = (type, company) ->
      switch type
        when 'disable'
          Egnyte.updateEgnyteSettings(egnyte_connected: $scope.company.egnyte_connected)
        when 'disconnect'
          Egnyte.updateEgnyteSettings(action_type: 'disconnect').then () ->
            $scope.init()

    $scope.init()

    $scope.submitForm = ->
      Egnyte.index().then (response) ->
        $window.location.href = response.egnyteTokenUrl
]