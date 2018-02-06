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
      Egnyte.show().then (egnyteSettings) ->
        $scope.egnyteSettings = egnyteSettings

    $scope.disconnectEgnyte = (egnyte) ->
      Egnyte.updateConfiguration(enabled: egnyte.connected)

    $scope.removeEgnyte = (egnyteSettings) ->
      if confirm('Are you sure?')
        Egnyte.disconnect().then () ->
          $scope.init()

    $scope.init()

    $scope.submitForm = ->
      Egnyte.egnyteSetup().then (response) ->
        $window.location.href = response.egnyte_login_uri
]