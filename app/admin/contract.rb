ActiveAdmin.register Contract do
  permit_params :company_id, :license_id, :start_date, :end_date

  index do
    selectable_column
    id_column
    column :company
    column :license
    column :start_date
    column :end_date
    actions
  end
end
