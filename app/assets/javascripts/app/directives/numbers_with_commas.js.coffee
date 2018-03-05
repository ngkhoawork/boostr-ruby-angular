@directives.directive 'numbersWithCommas', ->
  restrict: 'A',
  require: '?ngModel',

  link: (scope, element, attrs, ngModel) ->
    if !element.is 'input'
      inputModel = element.find('input.number').controller('ngModel')
      ngModel = inputModel if inputModel

    formatWithCommas = (value) ->
      if value
        parseInt(value).toLocaleString('en-US')
      else value

    #model -> view
    ngModel.$formatters.push (modelValue) ->
      formatWithCommas(modelValue || 0)

    #view -> model
    ngModel.$parsers.push (viewValue) ->
      parseInt viewValue.replace(/,/g, '')

    ngModel.$viewChangeListeners.push ->
      ngModel.$viewValue = formatWithCommas(ngModel.$modelValue)
      ngModel.$render()
