ActiveAdmin.register Stage do
  permit_params :name, :company_id, :probability, :open, :active, :position, :color
  filter :name
	filter :company
	filter :probability
	filter :open
	filter :active
end
