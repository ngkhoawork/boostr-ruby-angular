@app.controller 'ProfileController', [
  '$scope', 'CurrentUser', 'Egnyte', '$window', 'User', ($scope, CurrentUser, Egnyte, $window, User) ->
    $scope.init = () ->
      CurrentUser.get().$promise.then (user) ->
        $scope.egnyte_authenticated = user.egnyte_authenticated
        $scope.profile = {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email
        }

      Egnyte.show().then (egnyteSettings) ->
        $scope.egnyteEnabled = egnyteSettings.enabled

    $scope.submitForm = () ->
      formValidation()
      if Object.keys($scope.errors).length > 0 then return

      User.update($scope.profile).$promise.then (err, res) ->
        console.log(err)


    $scope.connectEgnyte = ->
      Egnyte.egnyteSetup().then (response) ->
        $window.location.href = response.egnyte_login_uri

    $scope.removeEgnyte = () ->
      if confirm('Are you sure?')
        Egnyte.disconnect().then () ->
          $scope.init()

    formValidation = () ->
      $scope.errors = {}
      emailRegExp = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
      fields = ['first_name', 'last_name', 'email']

      fields.forEach (key) ->
        field = $scope.profile[key]
        switch key
          when 'first_name'
            if !field then return $scope.errors[key] = 'First Name is required'
          when 'last_name'
            if !field then return $scope.errors[key] = 'Last Name is required'
          when 'email'
            if !field then return $scope.errors[key] = 'Email is required'
            if !emailRegExp.test(field) then return $scope.errors[key] = 'Email is not valid'

    $scope.init()
]
