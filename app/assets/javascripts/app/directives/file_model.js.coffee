@directives.directive 'fileModel', [
  '$parse'
  ($parse) ->
    {
      restrict: 'A'
      link: (scope, element, attrs) ->
        model = $parse(attrs.fileModel)
        modelSetter = model.assign
        element.bind 'change', ->
          scope.$apply ->
            if attrs.multiple
              modelSetter scope, element[0].files
            else
              modelSetter scope, element[0].files[0]
            return
          return
        return

    }
]