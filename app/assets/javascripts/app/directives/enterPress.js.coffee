# @directives.directive 'enterPress', ->
#         (scope, element, attrs) ->
#            element.bind 'keydown keypress', ->
#                 if (event.which === 13)
#                     scope.$apply ->
#                         scope.$eval(attrs.enterPress)
#
#                     event.preventDefault();

#app.directive 'enterKey', ($timeout) ->
#  (scope, elem, attrs) ->
#    elem.bind 'keydown', (e) ->
#      if e.keyCode is 13
#        $timeout ->
#          scope.$apply attrs.enterKey
#        , +attrs.enterKeyDelay

@directives.directive 'enterPress', ->
  (scope, elem, attrs) ->
    elem.bind 'keydown keypress', (e) ->
      if e.which is 13
        scope.$apply ->
          scope.$eval attrs.enterPress
        e.preventDefault();
