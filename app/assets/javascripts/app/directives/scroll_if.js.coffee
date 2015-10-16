@directives.directive 'scrollIf', ->
  (scope, element, attrs) ->
    scope.$watch attrs.scrollIf, (value) ->
      if value
        _.defer ->
          $(element).find('.editable:first-child').trigger('click')
