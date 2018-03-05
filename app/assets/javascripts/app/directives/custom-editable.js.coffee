@directives.directive 'clickToEdit', ($timeout) ->
  {
  require: 'ngModel'
  scope:
    model: '=ngModel'
    prefix: '@prefix'
    postfix: '@postfix'
    decimal: '@decimal'
    onAfterSave: '&onAfterSave'
    type: '@type'
  replace: true
  transclude: false
  template: '<div class="templateRoot">' +
    '<div class="editable" ng-show="!editState" ng-click="toggle()" ng-if="type==\'number\'">{{prefix}}{{(model ? model : 0) | number : (decimal && decimal > 0 ? decimal : 0)}}{{postfix}}</div>' +
    '<div class="editable" ng-show="!editState" ng-click="toggle()" ng-if="type!=\'number\'">{{prefix}}{{model}}{{postfix}}</div>' +
    '<input class="number editable-field" placeholder="0" type="text" ng-model="localModel" enter-press="toggle()" ng-show="editState && type == \'number\'" ng-blur="save()" numbers-with-commas/>' +
    '<input class="inputText editable-field" type="text" name="inputText" ng-model="localModel" enter-press="toggle()" ng-show="editState && type == \'inputText\'" ng-blur="save()"/>' +
    '</div>'
  link: (scope, element, attrs) ->
    scope.editState = false
    # make a local ref so we can back out changes, this only happens once and persists
    scope.localModel = scope.model
    # apply the changes to the real model

    scope.save = ->
      scope.model = scope.localModel
      $timeout (->
        # focus if in edit, blur if not. some IE will leave cursor without the blur
        scope.onAfterSave()
      ), 0
      scope.toggle()
      return

    # don't apply changes

    scope.cancel = ->
      scope.localModel = scope.model
      scope.toggle()
      return

    ###
    # toggles the editState of our field
    ###

    scope.toggle = ->
      scope.editState = !scope.editState

      ###
      # a little hackish - find the "type" by class query
      #
      ###

      x1 = element[0].querySelector('.' + scope.type)

      ###
      # could not figure out how to focus on the text field, needed $timout
      # http://stackoverflow.com/questions/14833326/how-to-set-focus-on-input-field-in-angularjs
      ###

      $timeout (->
        # focus if in edit, blur if not. some IE will leave cursor without the blur
        if scope.editState then x1.focus() else x1.blur()
        return
      ), 0
      return

    return

  }
