@directives.directive 'numbersWithCommas', ($filter) ->
  restrict: 'A',
  require: '?ngModel',

  link: (scope, element, attrs, ngModel) ->
    if !element.is 'input'
      inputModel = element.find('input.number').controller('ngModel')
      ngModel = inputModel if inputModel
      element = element.find('input.number')

    formatWithCommas = (value) ->
      if +value == 0
        return ''
      else
       $filter('currency')(+value, '', 0)

    #model -> view
    ngModel.$formatters.push (modelValue) ->
      if +modelValue == 0
        return 0
      else  
        formatWithCommas(modelValue)

    #view -> model
    ngModel.$parsers.push (viewValue) ->
      if +viewValue == 0
        return 0
      else  
        Number(viewValue.replace(/,/g, ''))

    countCommas = (string) ->
      commasQuantity = 0
      string.split('').forEach(
        (letter) ->
          if letter == ',' then commasQuantity++
      )
      commasQuantity

    ngModel.$viewChangeListeners.push ->
      prevCommasCount = countCommas(ngModel.$viewValue)
      prevModelValueLength = ngModel.$viewValue.length
      if prevModelValueLength % 4 == 1 && prevModelValueLength != 1
        prevModelValueLength--
      if element[0].nodeName != 'INPUT'
        element = element.find('input.number')
      caretPosition = element[0].selectionStart
      posA = element[0].selectionStart
      value = ngModel.$viewValue.replace(/[^0-9]/g, '')
      ngModel.$modelValue = ngModel.$viewValue
      ngModel.$viewValue = formatWithCommas(value)
      ngModel.$commitViewValue()
      ngModel.$render()
      posB = element[0].selectionStart
      currCommasCount = countCommas(ngModel.$viewValue)
      
      if posB > posA && posB == ngModel.$viewValue.length
        element[0].selectionStart = posB
        if posB - posA == 1
          element[0].selectionStart = posA
          if element[0].selectionEnd > element[0].selectionStart
            if prevModelValueLength != ngModel.$viewValue.length
              element[0].selectionStart = element[0].selectionEnd
              if currCommasCount == prevCommasCount
                element[0].selectionStart = posA
            else
              element[0].selectionStart = element[0].selectionEnd - 1
        else if posB - posA > 1
          element[0].selectionStart = posA
          if element[0].selectionEnd > element[0].selectionStart
            if prevModelValueLength != ngModel.$viewValue.length
              element[0].selectionStart = element[0].selectionEnd = element[0].selectionStart + 1
            else
              element[0].selectionStart = element[0].selectionEnd - 1
      else
        element[0].selectionStart = element[0].selectionEnd = caretPosition
        if currCommasCount > prevCommasCount
          element[0].selectionStart = element[0].selectionEnd = ++element[0].selectionStart
        if currCommasCount < prevCommasCount && element[0].selectionStart != ngModel.$viewValue.length
          element[0].selectionStart = element[0].selectionEnd = --element[0].selectionStart
        if currCommasCount < prevCommasCount && prevModelValueLength > ngModel.$viewValue.length
          element[0].selectionStart = element[0].selectionEnd = --caretPosition
        if currCommasCount == prevCommasCount && prevModelValueLength == ngModel.$viewValue.length
          element[0].selectionStart = element[0].selectionEnd = caretPosition  
      element.val(ngModel.$viewValue)
