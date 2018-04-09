app.directive 'autoColspan', ->
  restrict: 'C'
  scope: false
  link: ($scope, element) ->
    getColspan = () ->
      prevEl = element.parent().prev()
      if prevEl.length
        max = prevEl.children().length
      else
        table = element.closest('table')
        trs = table.find('thead').first().children()
        max = 0
        trs.each ->
          len = angular.element(this).children().length
          max = len if len > max
      max

    element.attr 'colspan', getColspan()
    
    $scope.$watch ->
      getColspan()
    , (newVal, oldVal)->
      if newVal != oldVal
        element.attr 'colspan', newVal
