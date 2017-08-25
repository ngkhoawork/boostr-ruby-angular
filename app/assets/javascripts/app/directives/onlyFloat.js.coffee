@directives.directive 'floatOnly', ->
  {
    require: 'ngModel'
    link: (scope, element, attr, ngModelCtrl) ->

      fromUser = (text) ->
        if text
          transformedInput = text.replace(/[^0-9\.]/g, '')
          if transformedInput != text
            ngModelCtrl.$setViewValue transformedInput
            ngModelCtrl.$render()
          return transformedInput
        undefined

      ngModelCtrl.$parsers.push fromUser
      return
  }
