@app.controller 'PublisherContactController', [
  '$scope', 'CountriesList', 'contact', 'ContactCfName', 'Contact', '$modalInstance', 'Publisher', '$routeParams', 'PublisherDetails', 'PublisherContact', '$rootScope', ($scope, CountriesList, contact, ContactCfName, Contact, $modalInstance, Publisher, $routeParams, PublisherDetails, PublisherContact, $rootScope) ->

    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.publisherContact = contact || {}
    $scope.query = ""
    $scope.countries = []
    $scope.contactCfNames = []
    type = "Add New"
    submitText = "Add"

    if $scope.publisherContact.id
      type = "Edit"
      submitText = "Update"

    $scope.formType = type
    $scope.submitText = submitText

    $scope.showAddressFields = Boolean(contact.address and
      (contact.address.country or
        contact.address.street1 or
        contact.address.city or
        contact.address.state or
        contact.address.zip))

    PublisherDetails.getPublisher(id: $routeParams.id).then (publisher) ->
      $scope.currentPublisher = publisher
      $scope.publisherContact.publisher_id = $scope.currentPublisher.id

    Publisher.publishersList().then (publishers) ->
      $scope.publishers = publishers

    CountriesList.get (data) ->
      $scope.countries = data.countries

    ContactCfName.all().then (contactCfNames) ->
      $scope.contactCfNames = contactCfNames

    $scope.getPublishers = (searchText) ->
      params = {}
      params.q = searchText
      Publisher.publishersList(params).then (publishers) ->
        $scope.publishers = publishers

    $scope.submitForm = () ->
      emailRegExp = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)

      $scope.errors = {}

      fields = ['name', 'publisher_id', 'address']

      fields.forEach (key) ->
        field = $scope.publisherContact[key]
        switch key
          when 'name'
            if !field then return $scope.errors[key] = 'Name is required'
          when 'publisher_id'
            if !field  then return $scope.errors[key] = 'Publisher is required'
          when 'address'
            if !field || !field.email then return $scope.errors.email = 'Email is required'
            if !emailRegExp.test(field.email) then return $scope.errors.email = 'Email is not valid'

      $scope.contactCfNames.forEach (item) ->
        if item.show_on_modal == true && item.is_required == true && (!$scope.publisherContact.contact_cf || !$scope.publisherContact.contact_cf[item.field_type + item.field_index])
          $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

      if Object.keys($scope.errors).length > 0 then return
      $scope.publisherContact.address_attributes = $scope.publisherContact.address
      $scope.contact_cf_attributes = $scope.publisherContact.contact_cf

      if $scope.publisherContact.id
        PublisherContact.update(id: $scope.publisherContact.id, contact: $scope.publisherContact).then (res) ->
          $rootScope.$broadcast 'updated_publisher_detail'
          $scope.cancel()
      else
        PublisherContact.create(contact: $scope.publisherContact).then (res) ->
          $rootScope.$broadcast 'updated_publisher_detail'
          $scope.cancel()

    $scope.cancel = ->
      $modalInstance.dismiss()
]