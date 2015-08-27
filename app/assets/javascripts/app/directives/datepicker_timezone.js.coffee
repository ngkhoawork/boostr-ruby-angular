app.directive 'datepickerTimezone', ->
  restrict: 'A'
  priority: 1
  require: 'ngModel'
  link: (scope, element, attrs, ctrl) ->
    ctrl.$formatters.push (value) ->
      date = new Date(Date.parse(value))
      date = new Date(date.getTime() + 60000 * date.getTimezoneOffset())
      date
    ctrl.$parsers.push (value) ->
      date = new Date(value.getTime() - (60000 * value.getTimezoneOffset()))
      date
    return
