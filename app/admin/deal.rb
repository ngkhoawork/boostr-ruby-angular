ActiveAdmin.register Deal do
  permit_params :name, :stage_id, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :next_steps, :company_id, :created_by
end
