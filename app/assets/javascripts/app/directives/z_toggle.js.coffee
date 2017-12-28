@directives.directive 'zToggle', ->
  restrict: 'E'
  replace: true
  require: 'ngModel',
  template: '<div class="z-toggle toggle-active"><span></span></div>'
  link: (scope, el, attrs, ngModel) ->

    ngModel.$render = -> el.toggleClass('toggle-active', Boolean ngModel.$viewValue)
    scope.$evalAsync -> ngModel.$render()

    el.bind 'click', ->
      ngModel.$setViewValue !ngModel.$viewValue
      ngModel.$render()


