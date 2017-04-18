@app.controller "SettingsDealCustomFieldNamesController",
['$scope', '$routeParams', '$location', '$modal', 'DealCustomFieldName', 'DealProductCfName', 'ContactCfName',
($scope, $routeParams, $location, $modal, DealCustomFieldName, DealProductCfName, ContactCfName) ->
  $scope.tables = ['Deal', 'Client', 'DealProduct']
  $scope.init = () ->
    getDealCustomFieldNames()
    getDealProductCfNames()
    getContactCfNames()

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  getDealProductCfNames = () ->
    DealProductCfName.all().then (dealProductCustomFieldNames) ->
      $scope.dealProductCustomFieldNames = dealProductCustomFieldNames

  getContactCfNames = () ->
    ContactCfName.all().then (results) ->
      $scope.contact_cf_names = results

  $scope.updateTimePeriod = (time_period_id) ->
    $location.path("/settings/deal_custom_field_names/#{time_period_id}")

  $scope.updateDealCustomFieldName = (dealCustomFieldName) ->
    DealCustomFieldName.update({id: dealCustomFieldName.id, dealCustomFieldName: dealCustomFieldName})

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_custom_field_name_form.html'
      size: 'lg'
      controller: 'SettingsDealCustomFieldNamesNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        customFieldName: ->
          {
            field_object: 'deal',
            field_type: null,
            field_label: "",
            required: false,
            position: null,
          }

  $scope.editModal = (customFieldName, objectType)->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_custom_field_name_form.html'
      size: 'lg'
      controller: 'SettingsDealCustomFieldNamesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        customFieldName: ->
          customFieldName
        objectType: ->
          objectType

  $scope.delete = (customFieldName, objectType) ->
    if confirm('Deleting a custom field will delete all values on records.  Click Ok to delete or Cancel.')
      if objectType == 'deal'
        DealCustomFieldName.delete(id: customFieldName.id)
      else if objectType == 'deal_product'
        DealProductCfName.delete(id: customFieldName.id)        
      else if objectType == 'contact'
        ContactCfName.delete(id: customFieldName.id)

  $scope.$on 'updated_deal_custom_field_names', ->
    getDealCustomFieldNames()
    getDealProductCfNames()
  $scope.$on 'updated_deal_product_cf_names', ->
    getDealCustomFieldNames()
    getDealProductCfNames()
  $scope.$on 'updated_contact_cf_names', ->
    getContactCfNames()

  $scope.init()

]
