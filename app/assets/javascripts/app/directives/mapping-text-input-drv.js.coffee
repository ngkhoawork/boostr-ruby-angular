@directives.directive 'zMappingTextInput', [
  '$document'
  ($document) ->
    scope: { messageText: '=', fieldMapping: '=' }
    templateUrl: 'directives/mapping-text-input.html'
    link: ($scope, element, attrs) ->
      linkFunc($scope, element, $document)
]

linkFunc = (scope, element, document) ->
  textarea = element.find('textarea.target')
  searchInput = element.find('input.search-field')
  modalWindow = $('#workflow-form-modal')
  dropdown = element.find('ul.dropdown-menu')
  scope.foundSuggestions = scope.fieldMapping
  scope.showSearch = false
  scope.suggestions = []
  scope.search = ''
  cursorPosition = textarea.val().length

  outsideClick = ->
    scope.showSearch = false
    scope.$apply()
    return

  document.bind 'click', outsideClick

  scope.$on '$destroy', -> document.unbind 'click', outsideClick

  scope.toogleSearch = ->
    scope.showSearch = !scope.showSearch
    event.stopPropagation()
    return

  modalWindow.on 'click', (event) ->
    if $(event.target).closest('.add-mapping').length == 0 and $(event.target).parent('.search-mapping-wrapper').length == 0
      scope.showSearch = false
    return

  scope.addSuggestionToText = (suggestion) ->
    scope.suggestions.push(suggestion)
    textareaValue = textarea.val()
    searchInput.val('')
    scope.showSearch = false
    scope.search = ''
    mapping = '{{' + suggestion.name + '}}'

    if textareaValue.length > 0
      output = textareaValue.slice(0, cursorPosition) + mapping + textareaValue.slice(cursorPosition);
    else
      output = textareaValue + mapping

    scope.messageText = output
    cursorPosition = cursorPosition + mapping.length

  scope.preventOutsideClick = ->
    event.stopPropagation()

  scope.checkCursorPosition = ->
    cursorPosition = textarea.prop("selectionStart")
