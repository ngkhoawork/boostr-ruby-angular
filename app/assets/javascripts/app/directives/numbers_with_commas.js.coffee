@directives.directive 'numbersWithCommas', ->
  restrict: 'A',
  require: '?ngModel',

  link: (scope, element, attrs, ngModel) ->
    formatWithCommas = (value) ->
      parseInt(value).toLocaleString('en-US')

    #model -> view
    ngModel.$formatters.push (modelValue) ->
      formatWithCommas(modelValue)

    #view -> model
    ngModel.$parsers.push (viewValue) ->
      parseInt viewValue.replace(/,/g, '')

    scope.$watch attrs.ngModel, (value) ->
      value = 0 if !value
      ngModel.$viewValue = formatWithCommas(value)
      element.val(ngModel.$viewValue)