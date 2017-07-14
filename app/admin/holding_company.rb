ActiveAdmin.register HoldingCompany do
  permit_params :name
  filter :name
end
