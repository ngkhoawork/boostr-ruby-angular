@service.service 'PMPType',
[() ->
  @all = [
    {name: 'Guaranteed', id: 'guaranteed'}
    {name: 'Non-Guaranteed', id: 'non_guaranteed'}
    {name: 'Always On', id: 'always_on'}
  ]

  @getName = (id) ->
    found = _.find(@all, (h) -> h.id == id)
    if found
      found.name
    else
      null

  return
]
