ActiveAdmin.register HoldingCompany do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    actions
  end

  show do
    attributes_table do
      row :name

    end
  end

  form do |f|
    f.inputs "Holding Company Details" do
      f.input :name
    end

    f.actions
  end

end
