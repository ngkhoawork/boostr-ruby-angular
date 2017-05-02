@service.service 'Field',
['$resource', '$q', '$rootScope', '$filter',
($resource, $q, $rootScope, $filter) ->

  resource = $resource '/api/fields/:id', { id: '@id' },

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (fields) ->
      deferred.resolve(fields)
    deferred.promise

  @get = (field_id) ->
    deferred = $q.defer()
    resource.get id: field_id, (field) ->
      deferred.resolve(field)
    deferred.promise

  @defaults = (subject, subject_type) ->
    deferred = $q.defer()
    finish = (fields) ->
      subject.fields = fields
      subject.values = subject.values || []
      _.each subject.fields, (field) ->
        values = $filter('filter')(subject.values, { field_id: field.id })
        if values.length > 0
          value = values[0]
          value.options = field.options
          value_option_ids = _.map(value.options, 'id')
          if value.option_id && value_option_ids.indexOf(value.option_id) < 0
            value.options.push(value.option)
        else
          subject.values.push({
            field_id: field.id
            options: field.options
          })
      deferred.resolve(subject.fields)

    if subject && subject.fields
      finish(subject.fields)
    else
      @all({ subject: subject_type }).then (fields) ->
        finish(fields)

    deferred.promise

  @field = (subject, field_name) ->
    if subject.fields && subject.fields.length > 0
      subject_field = $filter('filter')(subject.fields, { name: field_name })[0]
      if subject_field
        $filter('filter')(subject.values, { field_id: subject_field.id })[0]

  @getOption = (subject, field_name, option_id) ->
    if subject.fields && subject.fields.length > 0
      subject_field = $filter('filter')(subject.fields, { name: field_name })[0]
      if subject_field
        $filter('filter')(subject_field.options, { id: option_id })[0]

  @getSuboption = (subject, option, suboption_id) ->
    if option && option.suboptions && option.suboptions.length > 0
      suboption = $filter('filter')(option.suboptions, { id: suboption_id })[0]

  @findClientTypes = (fields) ->
    $filter('filter')(fields, { name: 'Client Type' })[0]

  @findFieldOptions = (fields, name) ->
    field = $filter('filter')(fields, { name: name })[0]
    if field
      return field.options
    else
      return []

    @findDealTypes = (fields) ->
    $filter('filter')(fields, { name: 'Deal Type' })[0]

  @findSources = (fields) ->
    $filter('filter')(fields, { name: 'Deal Source' })[0]
  return
]
