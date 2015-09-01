module CustomValues

  def objects
    [
      { name: 'Deals', fields_classes: [Stage]},
      { name: 'Clients', fields_classes: [] },
      { name: 'People', fields_classes: [] },
      { name: 'Teams', fields_classes: [] },
      { name: 'Employees', fields_classes: [] }
    ]
  end

  def fields(object)
    fields = []
    object[:fields_classes].each do |field|
      fields << {
        name: field.name.pluralize,
        values: values(field)
      }
    end
    fields
  end

  def values(field)
    send(field.name.tableize.to_sym)
  end

  def settings
    array = []
    objects.each do |object|
      array << {
        name: object[:name],
        fields: fields(object)
      }
    end
    array
  end

end