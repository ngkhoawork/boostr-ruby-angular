@app.controller 'PablisherNewController',
  ['$scope', '$modalInstance', 'Publisher', 'publisher', 'Client', 'CountriesList', 'PublisherCustomFieldName', '$rootScope',
    ($scope, $modalInstance, Publisher, publisher, Client, CountriesList, PublisherCustomFieldName, $rootScope) ->
      $scope.formType = "Add New"
      $scope.submitText = "Add"
      $scope.publisher = {comscore: false}
      $scope.clientSearch = ''
      $scope.countries = []
      $scope.publisherCustomFields = []
      $scope.showAddressFields = false

      $scope.init = () ->
        $scope.getClients()
        $scope.getPublisherSettings()
        $scope.getCountries()
        $scope.getPublisherCustomFields()

      $scope.getPublisherSettings = () ->
        Publisher.publisherSettings().then (settings) ->
          $scope.publisher_types = settings.publisher_types
          $scope.publisher_stages = settings.publisher_stages

      $scope.getClients = (query = '') ->
        Client.search_clients({name: query}).$promise.then (clients) ->
          $scope.clients = clients

      $scope.getPublisherCustomFields = () ->
        PublisherCustomFieldName.all({show_on_modal: true}).then (cf) ->
          $scope.publisherCustomFields = cf

      $scope.getCountries = () ->
        CountriesList.get (data) ->
          $scope.countries = data.countries

      $scope.submitForm = () ->
        formValidation()
        if Object.keys($scope.errors).length > 0 then return

        Publisher.create(publisher: $scope.publisher).then (response) ->
          $rootScope.$broadcast 'updated_publishers'
          $scope.cancel()
          # TODO need redirect to show publihser when will be ready

      formValidation = () ->
        $scope.errors = {}
        validUrl = new RegExp( /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/)

        fields = ['name', 'website']

        fields.forEach (key) ->
          field = $scope.publisher[key]
          switch key
            when 'name'
              if !field then return $scope.errors[key] = 'Name is required'
            when 'website'
              if field && !validUrl.test(field) then return $scope.errors[key] = 'Website URL is not valid'

        $scope.publisherCustomFields.forEach (item) ->
          if item.is_required && (!$scope.publisher.publisher_custom_field_attributes || !$scope.publisher.publisher_custom_field_attributes[item.field_type + item.field_index])
            $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

      $scope.cancel = ->
        $modalInstance.dismiss()

      $scope.init()
  ]