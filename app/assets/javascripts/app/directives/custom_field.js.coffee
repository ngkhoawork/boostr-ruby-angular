app.directive 'customField', [
  () ->
    restrict: 'E'
    replace: true
    scope:
        fieldType: '@'
        fieldLabel: '@'
        fieldName: '@'
        type: '@'
        customField: '='
        onUpdateField: '&'
        currencySymbol: '@'
        id: '@'
        options: '='
        required: '='
    templateUrl: 'directives/custom_field.html'
    link: ($scope, element) ->
      $scope.currencySymbol = $scope.currencySymbol || '$'
      $scope.customField = $scope.customField || {}
      $scope.value = $scope.customField[$scope.fieldName]
      $scope.type = $scope.type || 'showOnly'

      $scope.onUpdate = (value) ->
        $scope.value = value
        $scope.customField[$scope.fieldName] = value
        $scope.onUpdateField()

      $scope.inlineOrForm = () ->
        $scope.type == 'inlineEdit' || $scope.type == 'form'

      $scope.isRequired = () ->
        $scope.required && !$scope.value && $scope.fieldType != 'boolean'
]