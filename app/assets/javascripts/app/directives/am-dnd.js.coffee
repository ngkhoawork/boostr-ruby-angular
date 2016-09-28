@directives.directive 'amDnd', [
  # '$parse'
  () ->
    {
      scope:
        fileHanlder: '='
        filesHanlder: '='
      link: (scope, element, attrs) ->
        element.attr 'draggable', 'true'

        element[0].addEventListener 'dragover', (event) ->
          do event.preventDefault
          do event.stopPropagation
          element[0].classList.add('active');
        , false

        element[0].addEventListener 'dragleave', (event) ->
          do event.preventDefault
          do event.stopPropagation

          element[0].classList.remove('active');
        , false

        element[0].addEventListener 'drop', (event) ->
          do event.preventDefault

          file = event.dataTransfer.files[0];
          scope.fileHanlder file
          element[0].classList.remove('active');
    }
]