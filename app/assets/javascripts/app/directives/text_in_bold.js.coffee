@directives.directive 'textInBold', ->
  restrict: 'A',
  scope:
    text: '='
    lookup: '='
  link: (scope, element, attrs) ->
    index = scope.text.toLowerCase().indexOf(scope.lookup.toLowerCase())
    if index >= 0
      re = new RegExp("(" + scope.lookup + ")", "i");
      text =  scope.text.replace(re, '<strong>$1</strong>');
      element.html(text)
    else
      element.html(scope.text)
