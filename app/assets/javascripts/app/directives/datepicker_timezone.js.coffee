app.directive 'datepickerTimezone', ->
  restrict: 'A'
  priority: 1
  require: 'ngModel'
  link: (scope, element, attrs, ctrl) ->
    ctrl.$formatters.push (value) ->
      if value
        date = new Date(Date.parse(value))
        return new Date(date.getTime() + 60000 * date.getTimezoneOffset())
      else
        return value
    ctrl.$parsers.push (value) ->
      date = new Date(value.getTime() - (60000 * value.getTimezoneOffset()))
      date
    return