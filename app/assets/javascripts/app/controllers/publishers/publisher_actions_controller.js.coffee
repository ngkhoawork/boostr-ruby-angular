@app.controller 'PablisherActionsController',
  ['$scope', '$modalInstance', 'Publisher', 'publisher', 'PublisherCustomFieldName', 'CountriesList', '$rootScope', '$location', ($scope, $modalInstance, Publisher, publisher, PublisherCustomFieldName, CountriesList, $rootScope, $location) ->
    $scope.publisher = publisher
    $scope.publisherCustomFields = []
    $scope.publisher.comscore = false if _.isEmpty($scope.publisher)

    $scope.init = () ->
      $scope.getPublisherSettings()
      $scope.getCountries()
      $scope.getPublisherCustomFields()
      handleModalType()

    $scope.getPublisherSettings = () ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_types = settings.publisher_types
        $scope.publisher_stages = settings.publisher_stages
        $scope.renewal_term_fields = settings.renewal_term_fields

    $scope.getPublisherCustomFields = () ->
      PublisherCustomFieldName.all({show_on_modal: true}).then (cf) ->
        $scope.publisherCustomFields = cf

    $scope.getCountries = () ->
      CountriesList.get (data) ->
        $scope.countries = data.countries

    $scope.submitForm = () ->
      formValidation()
      if Object.keys($scope.errors).length > 0 then return
      handleRequestType()

    formValidation = () ->
      $scope.errors = {}
      fields = ['name']

      fields.forEach (key) ->
        field = $scope.publisher[key]
        switch key
          when 'name'
            if !field then return $scope.errors[key] = 'Name is required'

      $scope.publisherCustomFields.forEach (item) ->
        if item.is_required && (!$scope.publisher.publisher_custom_field_obj || !$scope.publisher.publisher_custom_field_obj[item.field_type + item.field_index])
          $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    handleRequestType = () ->
      $scope.publisher.address_attributes = $scope.publisher.address
      $scope.publisher.publisher_custom_field_attributes = $scope.publisher.publisher_custom_field_obj

      if $scope.publisher.id
        Publisher.update(id: $scope.publisher.id, publisher: $scope.publisher).then (response) ->
          $rootScope.$broadcast 'updated_publisher_detail'
          $scope.cancel()
      else
        Publisher.create(publisher: $scope.publisher).then (publisher) ->
          $location.url("/publishers/" + publisher.id)
          $scope.cancel()

    handleModalType = () ->
      type = "Add New"
      submitText = "Add"

      if $scope.publisher.id
        type = "Edit"
        submitText = "Update"

      $scope.formType = type
      $scope.submitText = submitText

    $scope.cancel = ->
      $modalInstance.close()

    $scope.init()
]