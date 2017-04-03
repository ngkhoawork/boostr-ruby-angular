@app.controller "SettingsDealCustomFieldNamesController",
['$scope', '$routeParams', '$location', '$modal', 'DealCustomFieldName', 'DealProductCfName',
($scope, $routeParams, $location, $modal, DealCustomFieldName, DealProductCfName) ->
  $scope.tables = ['Deal', 'Client', 'DealProduct']
  $scope.init = () ->
    getDealCustomFieldNames()
    getDealProductCfNames()

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames
  getDealProductCfNames = () ->
    DealProductCfName.all().then (dealProductCustomFieldNames) ->
      $scope.dealProductCustomFieldNames = dealProductCustomFieldNames

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
    if confirm('Are you sure you want to delete "' +  customFieldName.field_label + '"?')
      if objectType == 'deal'
        DealCustomFieldName.delete(id: customFieldName.id)
      else
        DealProductCfName.delete(id: customFieldName.id)

  $scope.$on 'updated_deal_custom_field_names', ->
    getDealCustomFieldNames()
    getDealProductCfNames()
  $scope.$on 'updated_deal_product_cf_names', ->
    getDealCustomFieldNames()
    getDealProductCfNames()

  $scope.init()

]