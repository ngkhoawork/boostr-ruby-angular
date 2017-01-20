app.directive 'addButton', ($timeout) ->
    restrict: 'A'
    link: (scope, element, attr) ->
        if scope.$last == true
            $timeout ->
                attr.onFinishRender()