ActiveAdmin.register Product do
  permit_params :name
  filter :name
	filter :company
	filter :revenue_type
	filter :active
end
