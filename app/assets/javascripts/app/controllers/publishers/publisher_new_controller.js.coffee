@app.controller 'PablisherNewController',
  ['$scope', '$modalInstance', 'Publisher', 'publisher', 'Client', 'CountriesList', ($scope, $modalInstance, Publisher, publisher, Client, CountriesList) ->
    $scope.formType = "Add New"
    $scope.submitText = "Add"
    $scope.publisher = { comscore: false }
    $scope.clientSearch = ''
    $scope.countries = []
    $scope.showAddressFields = Boolean(publisher.address_attributes and (
                                       publisher.address_attributes.country or
                                       publisher.address_attributes.street1 or
                                       publisher.address_attributes.city or
                                       publisher.address_attributes.state or
                                       publisher.address_attributes.zip))

    $scope.init = () ->
      $scope.getClients()
      $scope.getPublisherSettings()
      $scope.getCountries()

    $scope.getPublisherSettings = () ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_types = settings.publisher_types
        $scope.publisher_stages = settings.publisher_stages

    $scope.getClients = (query = '') ->
      Client.search_clients({name: query}).$promise.then (clients) ->
        $scope.clients = clients

    $scope.getCountries = () ->
      CountriesList.get (data) ->
        $scope.countries = data.countries

    $scope.submitForm = () ->
      $scope.errors = {}
      fields = ['name', 'type_id', 'client_id']

      fields.forEach (key) ->
        field = $scope.publisher[key]
        switch key
          when 'name'
            if !field then return $scope.errors[key] = 'Name is required'
          when 'type_id'
            if !field then return $scope.errors[key] = 'Type is required'
          when 'client_id'
            if !field then return $scope.errors[key] = 'Client is required'

      if Object.keys($scope.errors).length > 0 then return

      Publisher.create(publisher: $scope.publisher).then (response) ->
        $scope.cancel()
        # TODO need redirect to show publihser when will be ready

    $scope.cancel = ->
      $modalInstance.dismiss()

    $scope.init()
    
  ]