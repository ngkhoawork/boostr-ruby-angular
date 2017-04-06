app.directive 'downloadButton', ->
    restrict: 'E'
    transclude: true
    template: '
        <button class="download-btn">
            <i class="fa fa-arrow-down"></i>
            <ng-transclude/>
        </button>
    '