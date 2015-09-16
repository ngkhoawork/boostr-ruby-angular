@directives.directive 'server', ->
  restrict: 'A',
  require: '?ngModel',
  link: ($scope, el, attrs, ctrl) ->
    $scope.$watch attrs.ngModel, (value) ->
      ctrl.$setValidity('server', true)


