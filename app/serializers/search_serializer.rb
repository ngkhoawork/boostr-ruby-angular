class SearchSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :searchable_id,
    :searchable_type,
    :details
  )

  def details
    case object.searchable_type
    when 'Client'
      object.searchable.as_json({
        override: true,
        only: [:id, :name],
        include: {
          client_category: {
            only: [:id, :name]
          },
          client_members: {
            only: [:share],
            include: {
              user: {
                only: [],
                methods: [:name]
              }
            }
          }
        },
        methods: [:client_type]
      })
    when 'Deal'
      object.searchable.as_json({
        override: true,
        options: {
          only: [:id, :name, :budget_loc, :budget, :start_date, :end_date],
          include: {
            advertiser: {
              only: [:id, :name]
            },
            agency: {
              only: [:id, :name]
            },
            stage: {
              only: [:name, :probability]
            },
            currency: {}
          } 
        }
      })
    when 'Io'
      object.searchable.as_json({
        override: true,
        only: [:id, :io_number, :name, :budget, :budget_loc, :start_date, :end_date],
        include: {
          advertiser: {
            only: [:id, :name]
          },
          agency: {
            only: [:id, :name]
          },
          currency: {}
        }
      })
    when 'Contact'
      object.searchable.as_json({
        only: [:id, :name, :position],
        methods: [:email],
        include: {
          clients: {
            only: [:id, :name]
          }
        }
      })
    end
  end
end
