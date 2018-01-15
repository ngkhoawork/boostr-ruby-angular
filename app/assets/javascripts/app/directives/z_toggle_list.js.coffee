@directives.directive 'zToggleList', ['$timeout', ($timeout)->
    restrict: 'E'
    replace: true
    scope:
        list: '='
        selected: '='
        vertical: '='
        onChange: '&'
    template: """
        <div class="z-toggle-list toggle-active">
            <div class="selected-line"></div>
            <div class="z-toggle-list-item" ng-repeat="item in list" ng-class="{active: item == $selected}" ng-click="setItem(item)">
                <span>{{item.name}}</span>
            </div>
        </div>
    """
    link: (scope, el, attrs) ->
        if scope.vertical then el.addClass 'vertical'
        scope.$selected = scope.selected || scope.list[0]

        scope.setItem = (item) ->
            scope.onChange({$selected: item})
            scope.$selected = item
            updateLine()

        $timeout -> updateLine()

        updateLine = ->
            duration = 250
            line = el.find('.selected-line')
            prevSelection = el.find('.active')
            $timeout ->
                nextSelection = el.find('.active')
                prevPosition = prevSelection.position()
                nextPosition = nextSelection.position()
                nextWidth = nextSelection.outerWidth()
                nextHeight = nextSelection.outerHeight()
                switch true
                    when prevPosition.left > nextPosition.left #LEFT
                        step1 =
                            width: prevPosition.left + prevSelection.outerWidth() - nextPosition.left
                            left: nextPosition.left
                        step2 =
                            width: nextSelection.outerWidth() + nextWidth * .1
                            left: nextPosition.left - nextWidth * .05
                    when nextPosition.left > prevPosition.left #RIGHT
                        step1 =
                            width: nextPosition.left + nextSelection.outerWidth() - prevPosition.left
                            left: prevPosition.left
                        step2 =
                            width: nextSelection.outerWidth() + nextWidth * .1
                            left: nextPosition.left - nextWidth * .05
                    when scope.vertical && prevPosition.top > nextPosition.top #UP
                        step1 =
                            height: prevPosition.top + prevSelection.outerHeight() - nextPosition.top
                            top: nextPosition.top
                        step2 =
                            height: prevSelection.outerHeight() + nextHeight * .1
                            top: nextPosition.top - nextHeight * .05
                    when scope.vertical && nextPosition.top > prevPosition.top #DOWN
                        step1 =
                            height: nextPosition.top + nextSelection.outerHeight() - prevPosition.top
                            top: prevPosition.top
                        step2 =
                            height: nextSelection.outerHeight() + nextHeight * .1
                            top: nextPosition.top - nextHeight * .05
                    else
                        step2 = if scope.vertical
                            height: nextSelection.outerHeight() + nextHeight * .1
                            top: nextPosition.top - nextHeight * .05
                        else
                            width: nextSelection.outerWidth() + nextWidth * .1
                            left: nextPosition.left - nextWidth * .05
                        step1 = step2
                        duration = 0

                line.animate(step1, duration).animate(step2, duration)
]