@app.controller 'PablisherActionsController',
  ['$scope', '$modalInstance', 'Publisher', 'publisher', 'PublisherCustomFieldName', 'CountriesList', '$rootScope', ($scope, $modalInstance, Publisher, publisher, PublisherCustomFieldName, CountriesList, $rootScope) ->
    $scope.publisher = publisher
    $scope.publisherCustomFields = []

    $scope.init = () ->
      $scope.getPublisherSettings()
      $scope.getCountries()
      $scope.getPublisherCustomFields()
      handleModalType()

    $scope.getPublisherSettings = () ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_types = settings.publisher_types
        $scope.publisher_stages = settings.publisher_stages

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
        Publisher.create(publisher: $scope.publisher).then (response) ->
          $rootScope.$broadcast 'updated_publishers'
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