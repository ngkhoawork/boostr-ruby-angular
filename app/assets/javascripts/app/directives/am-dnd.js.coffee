@directives.directive 'amDnd', [
  # '$parse'
  () ->
    {
      scope:
        fileHanlder: '='
        filesHanlder: '='
      link: (scope, element, attrs) ->
        element.attr 'draggable', 'true'

        element.on 'dragenter', (event) ->
          if element[0] != event.target
            return

          element[0].classList.add('active');
          console.log 'dragEnter'

        element.on 'dragleave', (event) ->
          if element[0] != event.target
            return
            # element.removeClass("child-elements");
          element[0].classList.remove('active');
          console.log 'dragleave'

        element.on 'dragover', (event) ->
          do event.preventDefault

        element.on 'drop', (event) ->
          do event.preventDefault
          # console.log 'event', event
          file = event.originalEvent.dataTransfer.files[0];
          scope.fileHanlder file
          element[0].classList.remove('active');
          # console.log 'files:', files
    }
]