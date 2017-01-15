@app.controller "SettingsDealCustomFieldNamesController",
['$scope', '$routeParams', '$location', '$modal', 'DealCustomFieldName',
($scope, $routeParams, $location, $modal, DealCustomFieldName) ->
  $scope.tables = ['Deal', 'Client', 'DealProduct']
  $scope.init = () ->
    getDealCustomFieldNames()

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

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
        dealCustomFieldName: ->
          {
            field_type: null,
            field_label: "",
            required: false,
            position: null,
          }

  $scope.editModal = (dealCustomFieldName)->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_custom_field_name_form.html'
      size: 'lg'
      controller: 'SettingsDealCustomFieldNamesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        dealCustomFieldName: ->
          dealCustomFieldName

  $scope.delete = (dealCustomFieldName) ->
    if confirm('Are you sure you want to delete "' +  dealCustomFieldName.field_label + '"?')
      DealCustomFieldName.delete(id: dealCustomFieldName.id).then() ->
        getDealCustomFieldNames()

  $scope.$on 'updated_deal_custom_field_names', ->
    getDealCustomFieldNames()

  $scope.init()

]