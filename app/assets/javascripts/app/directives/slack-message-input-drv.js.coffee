@directives.directive 'zSlackMessageInput', [
  ->
    link: linkFunc
    scope: { messageText: '=', fieldMapping: '=' }
    templateUrl: 'directives/slack-message-input.html'
]

linkFunc = (scope, element) ->
  textarea = element.find('textarea')
  searchInput = element.find('input.search-field')
  modalWindow = $('#workflow-form-modal')
  dropdown = element.find('ul.dropdown-menu')
  scope.foundSuggestions = scope.fieldMapping
  scope.showSearch = false
  scope.suggestions = []
  scope.search = ''
  cursorPosition = textarea.val().length

  scope.toogleSearch = ->
    scope.showSearch = !scope.showSearch
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

  scope.checkCursorPosition = ->
    cursorPosition = textarea.prop("selectionStart")
    