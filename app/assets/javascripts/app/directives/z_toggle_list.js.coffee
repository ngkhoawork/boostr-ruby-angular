@directives.directive 'zToggleList', ['$timeout', 'localStorageService', ($timeout, LS)->
    restrict: 'E'
    replace: true
    scope:
        list: '='
        selected: '='
        vertical: '='
        localstorage: '@'
        onChange: '&'
    template: """
        <div class="z-toggle-list toggle-active">
            <div class="selected-line"></div>
            <div class="z-toggle-list-item" ng-repeat="item in list" ng-class="{active: item.id == selected.id}" ng-click="setItem(item)">
                <span>{{item.name}}</span>
            </div>
        </div>
    """
    link: (scope, el, attrs) ->
        if scope.vertical then el.addClass 'vertical'
        storedValue = LS.get(scope.localstorage) if scope.localstorage
        scope.selected = scope.selected || storedValue || scope.list[0]

        scope.setItem = (item) ->
            scope.selected = item
            LS.set(scope.localstorage, item) if scope.localstorage
            updateLine()
            $timeout ->
                scope.onChange({$selected: item})

        $timeout -> scope.setItem(scope.selected)

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
                    when prevSelection && prevPosition.left > nextPosition.left #LEFT
                        step1 =
                            width: prevPosition.left + prevSelection.outerWidth() - nextPosition.left
                            left: nextPosition.left
                        step2 =
                            width: nextSelection.outerWidth() + nextWidth * .1
                            left: nextPosition.left - nextWidth * .05
                    when prevSelection && nextPosition.left > prevPosition.left #RIGHT
                        step1 =
                            width: nextPosition.left + nextSelection.outerWidth() - prevPosition.left
                            left: prevPosition.left
                        step2 =
                            width: nextSelection.outerWidth() + nextWidth * .1
                            left: nextPosition.left - nextWidth * .05
                    when prevSelection && scope.vertical && prevPosition.top > nextPosition.top #UP
                        step1 =
                            height: prevPosition.top + prevSelection.outerHeight() - nextPosition.top
                            top: nextPosition.top
                        step2 =
                            height: prevSelection.outerHeight() + nextHeight * .1
                            top: nextPosition.top - nextHeight * .05
                    when prevSelection && scope.vertical && nextPosition.top > prevPosition.top #DOWN
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
                        return line.css step2

                line.animate(step1, duration).animate(step2, duration)
]