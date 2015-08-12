ActiveAdmin.register Product do
  permit_params :name, :product_line, :family, :pricing_type
end
