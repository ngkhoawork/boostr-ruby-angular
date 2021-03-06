@app.controller "SettingsDealCustomFieldNamesController",
['$scope', '$routeParams', '$location', '$modal', 'CustomFieldNames', 'DealCustomFieldName', 'DealProductCfName', 'AccountCfName', 'ContactCfName', 'PublisherCustomFieldName',
($scope, $routeParams, $location, $modal, CustomFieldNames, DealCustomFieldName, DealProductCfName, AccountCfName, ContactCfName, PublisherCustomFieldName) ->
  $scope.tables = ['Deal', 'Client', 'DealProduct']
  $scope.init = () ->
    getDealCustomFieldNames()
    getDealProductCfNames()
    getAccountCfNames()
    getContactCfNames()
    getPublisherCustomFieldName()
    getCustomFieldNames()

  getCustomFieldNames = () ->
    CustomFieldNames.all({'subject_type[]': ['activity', 'content_fee', 'pmp_item']}).then (customFieldNames) ->
      $scope.pmpItemCustomFieldNames = _.filter customFieldNames, (c) -> c.subject_type == 'PmpItem'
      $scope.activityCustomFieldNames = _.filter customFieldNames, (c) -> c.subject_type == 'Activity'
      $scope.contentFeeCustomFieldNames = _.filter customFieldNames, (c) -> c.subject_type == 'ContentFee'

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  getDealProductCfNames = () ->
    DealProductCfName.all().then (dealProductCustomFieldNames) ->
      $scope.dealProductCustomFieldNames = dealProductCustomFieldNames

  getAccountCfNames = () ->
    AccountCfName.all().then (accountCustomFieldNames) ->
      $scope.accountCustomFieldNames = accountCustomFieldNames

  getContactCfNames = () ->
    ContactCfName.all().then (results) ->
      $scope.contact_cf_names = results

  getPublisherCustomFieldName = () ->
    PublisherCustomFieldName.all().then (results) ->
      $scope.publisher_custom_field_names = results

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
    customFieldName = angular.copy customFieldName
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_custom_field_name_form.html'
      size: 'lg'
      controller: 'SettingsDealCustomFieldNamesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        customFieldName: ->
          customFieldName = customFieldName
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
      else if objectType == 'account'
        AccountCfName.delete(id: customFieldName.id)
      else if objectType == 'publisher'
        PublisherCustomFieldName.delete(id: customFieldName.id)
      else
        CustomFieldNames.delete(subject_type: objectType, id: customFieldName.id)

  $scope.$on 'updated_deal_custom_field_names', ->
    $scope.init()
  $scope.$on 'updated_deal_product_cf_names', ->
    $scope.init()
  $scope.$on 'updated_account_cf_names', ->
    $scope.init()
  $scope.$on 'updated_contact_cf_names', ->
    $scope.init()
  $scope.$on 'updated_publisher_custom_field_names', ->
    $scope.init()
  $scope.$on 'updated_custom_field_names', ->
    $scope.init()

  $scope.init()

]
