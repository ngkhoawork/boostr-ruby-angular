@directives.directive 'amDnd', [
  # '$parse'
  () ->
    {
      scope:
        fileHanlder: '='
        filesHanlder: '='
      link: (scope, element, attrs) ->
        element.on 'drag dragstart dragend dragover dragenter dragleave drop', (e) ->
          doNothing e
        .on 'dragover dragenter', (e) ->
          element[0].classList.add 'active'
        .on 'dragleave dragend drop', (e) ->
          element[0].classList.remove 'active'
        .on 'drop', (e) ->
          file = event.dataTransfer.files[0];
          scope.fileHanlder file

        doNothing = (e) ->
          do e.stopPropagation
          do e.preventDefault
    }
]