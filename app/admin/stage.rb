ActiveAdmin.register Stage do
  permit_params :name, :company_id, :probability, :open, :active, :position, :color
end
