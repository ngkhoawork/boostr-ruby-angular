@directives.directive 'zColoringStage', ['$window', 'shadeColor', ($window, shadeColor) ->
    restrict: 'CA'
    scope:
        params: '=zColoringStage'
    link: ($scope, el) ->
        stage = $scope.params.stage
        color = if !stage.is_open && stage.probability == 0
        then '#cbcbcb'
        else shadeColor $scope.params.color, 0.8 - 0.8 / 100 * stage.probability
        svgPolygon = el.find('polygon')
        el.css('backgroundColor', color)
        svgPolygon.css('fill', color)
]

