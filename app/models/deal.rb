require 'rubygems'
require 'zip'

class Deal < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id', counter_cache: :advertiser_deals_count
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id', counter_cache: :agency_deals_count
  belongs_to :stage, counter_cache: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :stage_updator, class_name: 'User', foreign_key: 'stage_updated_by'
  belongs_to :previous_stage, class_name: 'Stage', foreign_key: 'previous_stage_id'

  has_one :io, class_name: "Io", foreign_key: 'io_number'

  has_many :contacts, -> { uniq }, through: :deal_contacts
  has_many :deal_contacts, dependent: :destroy
  has_many :deal_products
  has_many :deal_product_budgets, through: :deal_products
  has_many :deal_logs
  has_many :products, -> { distinct }, through: :deal_products
  has_many :deal_members
  has_many :users, through: :deal_members
  has_many :values, as: :subject
  has_many :deal_stage_logs
  has_many :activities
  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :assets, as: :attachable

  validates :advertiser_id, :start_date, :end_date, :name, :stage_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  before_save do
    if deal_product_budgets.empty?
      self.budget = budget.to_i * 100 if budget_changed?
    end
  end

  before_update do
    if stage_id_changed?
      update_stage
      update_close
    end
  end

  after_update do
    # if stage_id_changed?
    #   update_close
    # end
    generate_io() if stage_id_changed?
    reset_products if (start_date_changed? || end_date_changed?)
    log_stage if stage_id_changed?
  end

  before_create do
    update_stage
  end

  after_create do
    generate_deal_members
  end

  before_destroy do
    update_stage
  end

  after_destroy do
    log_stage
  end

  scope :for_client, -> (client_id) { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }
  scope :for_time_period, -> (start_date, end_date) { where('deals.start_date <= ? AND deals.end_date >= ?', end_date, start_date) }
  scope :closed_in, -> (duration_in_days) { where('deals.closed_at >= ?', Time.now.utc.beginning_of_day - duration_in_days.days) }
  scope :closed_at, -> (start_date, end_date) { where('deals.closed_at >= ? and deals.closed_at <= ?', start_date, end_date) }
  scope :started_at, -> (start_date, end_date) { where('deals.created_at >= ? and deals.created_at <= ?', start_date, end_date) }
  scope :open, -> { joins(:stage).where('stages.open IS true') }
  scope :open_partial, -> { where('deals.open IS true') }
  scope :closed, -> { joins(:stage).where('stages.open IS false') }
  scope :active, -> { where('deals.deleted_at is NULL') }
  scope :at_percent, -> (percentage) { joins(:stage).where('stages.probability = ?', percentage) }
  scope :greater_than, -> (percentage) { joins(:stage).where('stages.probability >= ?', percentage) }
  scope :more_than_percent, -> (percentage)  { joins(:stage).where('stages.probability >= ?', percentage) }

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    name + ', '+ advertiser.name + ', '+ stage.name
  end

  def as_json(options = {})
    super(options.merge(
              include: [
                  :creator,
                  :advertiser,
                  :agency,
                  :stage,
                  :values,
                  deal_members: {
                      methods: [:name]
                  },
                  activities: {
                      include: {
                          creator: {},
                          contacts: {},
                          assets: {
                              methods: [
                                  :presigned_url
                              ]
                          }
                      }
                  }
              ],
              methods: [
                  :formatted_name
              ]
          )
    )
  end

  def as_weighted_pipeline(start_date, end_date)
    weighted_pipeline = {
      id: id,
      name: name,
      client_name: advertiser.name,
      probability: stage.probability,
      stage_id: stage.id,
      budget: budget,
      in_period_amt: in_period_amt(start_date, end_date),
      wday_in_stage: wday_in_stage,
      wday_since_opened: wday_since_opened,
      start_date: self.start_date
    }

    if stage.red_threshold.present? or stage.yellow_threshold.present?
      if stage.red_threshold.present? and wday_in_stage >= stage.red_threshold
        weighted_pipeline[:wday_in_stage_color] = 'red'
      elsif stage.yellow_threshold.present? and wday_in_stage >= stage.yellow_threshold
        weighted_pipeline[:wday_in_stage_color] = 'yellow'
      else
        weighted_pipeline[:wday_in_stage_color] = 'green'
      end
    end

    if company.red_threshold.present? or company.yellow_threshold.present?
      if company.red_threshold.present? and wday_since_opened >= company.red_threshold
        weighted_pipeline[:wday_since_opened_color] = 'red'
      elsif company.yellow_threshold.present? and wday_since_opened >= company.yellow_threshold
        weighted_pipeline[:wday_since_opened_color] = 'yellow'
      else
        weighted_pipeline[:wday_since_opened_color] = 'green'
      end
    end

    weighted_pipeline
  end

  def in_period_amt(start_date, end_date)
    deal_product_budgets.for_time_period(start_date, end_date).to_a.sum do |deal_product_budget|
      from = [start_date, deal_product_budget.start_date].max
      to = [end_date, deal_product_budget.end_date].min
      num_days = (to.to_date - from.to_date) + 1
      deal_product_budget.daily_budget * num_days
    end
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def days_per_month
    array = []

    case months.length
    when 0
      array
    when 1
      array << days
    when 2
      array << ((start_date.end_of_month + 1) - start_date).to_i
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    else
      array << ((start_date.end_of_month + 1) - start_date).to_i
      (months[1..-2] || []).each do |month|
        array << Time.days_in_month(month[1], month[0])
      end
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    end
    array
  end

  def update_total_budget
    current_budget = self.budget.nil? ? 0 : self.budget
    new_budget = deal_product_budgets.sum(:budget)
    deal_log = DealLog.new
    deal_log.deal_id = self.id
    deal_log.budget_change = new_budget - current_budget
    deal_log.save
    update_attributes(budget: deal_products.sum(:budget))
  end

  def reset_products
    # This only happens if start_date or end_date has changed on the Deal and thus it has already be touched
    ActiveRecord::Base.no_touching do
      deal_products.each do |deal_product|
        deal_product.deal_product_budgets.destroy_all
        deal_product.create_product_budgets
      end
    end
  end

  def generate_deal_members
    # This only gets called on create where the Deal has inherently been touched
    ActiveRecord::Base.no_touching do
      if advertiser.client_members.empty? && creator
        deal_member = deal_members.create(user_id: creator.id, share: 100)
      else
        advertiser.client_members.each do |client_member|
          deal_member = deal_members.create(client_member.defaults)

          if client_member.role_value_defaults
            deal_member.values.create(client_member.role_value_defaults)
          end
        end
      end
    end
  end

  def self.get_option(subject, field_name)
    if !subject.nil?
      subject_fields = subject.fields
      if !subject_fields.nil?
        field = subject_fields.find_by_name(field_name)
        value = subject.values.find_by_field_id(field.id) if !field.nil?
        option = value.option.name if !value.nil? && !value.option.nil?
      end
    end
    return option
  end

  def latest_activity
    activities = self.activities.order("happened_at desc")
    if activities && activities.count > 0
      last_activity = activities.first
      data = ""
      if last_activity.happened_at
        data = data + "Date: " + last_activity.happened_at.strftime("%m-%d-%Y %H:%M:%S") + "\n"
      end
      if last_activity.activity_type_name
        data = data + "Type: " + last_activity.activity_type_name + "\n"
      end
      if last_activity.comment
        data = data + "Note: " + last_activity.comment
      end
      data
    else
      ""
    end
  end
  def self.to_pipeline_report_csv(company, team_id)
    CSV.generate do |csv|
      all_members_list = []

      deals = []
      if team_id == "0"
        deals = company.deals.active
      else
        selected_team = Team.find(team_id)
        all_members_list = selected_team.all_members.collect{|member| member.id}
        all_members_list += selected_team.all_leaders.collect{|member| member.id}
        deals = company.deals.joins("left join deal_members on deals.id = deal_members.deal_id").where("deal_members.user_id in (?) and deals.deleted_at is NULL", all_members_list).distinct
      end

      deal_ids = deals.collect{|deal| deal.id}
      range = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id=deal_products.id").select("distinct(start_date)").where("deal_products.deal_id in (?)", deal_ids).order("start_date asc").collect{|deal_product_budget| deal_product_budget.start_date}
      header = []
      header << "Team Member"
      header << "Advertiser"
      header << "Name"
      header << "Agency"
      header << "Stage"
      header << "%"
      header << "Budget"
      header << "Latest Activity"
      header << "Next Steps"
      header << "Start Date"
      header << "End Date"
      range.each do |product_time|
        header << product_time.strftime("%Y-%m")
      end

      csv << header
      deals.each do |deal|

        line = [
            deal.deal_members.collect {|deal_member| deal_member.user.first_name + " " + deal_member.user.last_name + " (" + deal_member.share.to_s + "%)"}.join(";"),
            deal.advertiser ? deal.advertiser.name : nil,
            deal.name,
            deal.agency ? deal.agency.name : nil,
            deal.stage.name,
            deal.stage.probability.nil? ? "" : deal.stage.probability.to_s + "%",
            "$" + ((deal.budget.nil? ? 0 : deal.budget) / 100).round.to_s
        ]
        line << deal.latest_activity
        line << deal.next_steps
        line << deal.start_date
        line << deal.end_date
        range.each do |product_time|
          deal_product_budgets = deal.deal_product_budgets.where({start_date: product_time}).select("sum(deal_product_budgets.budget) as total_budget").collect{|deal_product_budget| deal_product_budget.total_budget}

          if deal_product_budgets && deal_product_budgets[0]
            line << "$" + (deal_product_budgets[0] / 100).round.to_s
          else
            line << "$0"
          end
        end

        csv << line
      end
    end
  end

  def self.to_pipeline_summary_report_csv(company)
    CSV.generate do |csv|
      deals = company.deals.active.greater_than(50)
      data = {
        'Summary' => {
          '50% Prospects' => nil,
          '75% Prospects' => nil,
          '90% Prospects' => nil,
          'Booked' => nil,
          'Total' => nil
        },
        'Booked' => nil,
        '50% Prospects' => nil,
        '75% Prospects' => nil,
        '90% Prospects' => nil
      }

      current_year = Time.now.utc.year
      deals.each do |deal|
        if deal.stage.probability == 100
          percent_key = "Booked"
        else
          percent_key = deal.stage.probability.to_s + "% Prospects"
        end
        if (!data['Summary']['Total'])
          data['Summary']['Total'] = {}
          for i in 1..12
            data['Summary']['Total'][i.to_s] = 0
          end
          for i in 1..4
            data['Summary']['Total']['Q' + i.to_s] = 0
            data['Summary']['Total']['FY'] = 0
          end

        end
        if (!data['Summary'][percent_key])
          data['Summary'][percent_key] = {}
          for i in 1..12
            data['Summary'][percent_key][i.to_s] = 0
          end
          for i in 1..4
            data['Summary'][percent_key]['Q' + i.to_s] = 0
            data['Summary'][percent_key]['FY'] = 0
          end
        end
        if (!data[percent_key])
          data[percent_key] = {}
        end

        deal.deal_products.each do |deal_product|
          month = deal_product.start_date.month
          if deal_product.start_date.year != current_year
            next
          end
          data['Summary'][percent_key]['FY'] += deal_product.budget
          data['Summary'][percent_key][month.to_s] += deal_product.budget
          data['Summary'][percent_key]['Q' + ((month / 3.0).ceil.to_s)] += deal_product.budget
          data['Summary']['Total']['FY'] += deal_product.budget
          data['Summary']['Total'][month.to_s] += deal_product.budget
          data['Summary']['Total']['Q' + ((month / 3.0).ceil.to_s)] += deal_product.budget

          deal.deal_members.each do |deal_member|
            user = deal_member.user
            user_key = user.first_name + ' ' + user.last_name

            if (!data[percent_key][user_key])
              data[percent_key][user_key] = {}
              for i in 1 .. 12
                data[percent_key][user_key][i.to_s] = 0
              end
              for i in 1 .. 4
                data[percent_key][user_key]['Q' + i.to_s] = 0
                data[percent_key][user_key]['FY'] = 0
              end
            end

            if (!data[percent_key]['Total'])
              data[percent_key]['Total'] = {}
              for i in 1 .. 12
                data[percent_key]['Total'][i.to_s] = 0
              end
              for i in 1 .. 4
                data[percent_key]['Total']['Q' + i.to_s] = 0
                data[percent_key]['Total']['FY'] = 0
              end
            end
            user_product_budget = deal_product_budget.budget * deal_member.share / 100
            data[percent_key][user_key]['FY'] += user_product_budget
            data[percent_key][user_key][month.to_s] += user_product_budget
            data[percent_key][user_key]['Q' + ((month / 3.0).ceil.to_s)] += user_product_budget
            data[percent_key]['Total']['FY'] += user_product_budget
            data[percent_key]['Total'][month.to_s] += user_product_budget
            data[percent_key]['Total']['Q' + ((month / 3.0).ceil.to_s)] += user_product_budget
          end
        end
      end

      data.each do |title, data_obj|
        header = [
            title,
            "Jan",
            "Feb",
            "Mar",
            "Q1 Total",
            "Apr",
            "May",
            "Jun",
            "Q2 Total",
            "Jul",
            "Aug",
            "Sep",
            "Q3 Total",
            "Oct",
            "Nov",
            "Dec",
            "Q4 Total",
            "FY Total",
        ]
        csv << header


        if data_obj.nil?
          next
        end

        data_obj.each do |key,row|
          if key == "Total" || row.nil?
            next
          end
          line = [
            key,
            "$" + (row['1'] / 100).round.to_s,
            "$" + (row['2'] / 100).round.to_s,
            "$" + (row['3'] / 100).round.to_s,
            "$" + (row['Q1'] / 100).round.to_s,
            "$" + (row['4'] / 100).round.to_s,
            "$" + (row['5'] / 100).round.to_s,
            "$" + (row['6'] / 100).round.to_s,
            "$" + (row['Q2'] / 100).round.to_s,
            "$" + (row['7'] / 100).round.to_s,
            "$" + (row['8'] / 100).round.to_s,
            "$" + (row['9'] / 100).round.to_s,
            "$" + (row['Q3'] / 100).round.to_s,
            "$" + (row['10'] / 100).round.to_s,
            "$" + (row['11'] / 100).round.to_s,
            "$" + (row['12'] / 100).round.to_s,
            "$" + (row['Q4'] / 100).round.to_s,
            "$" + (row['FY'] / 100).round.to_s
          ]
          csv << line
        end
        line = [
            "Total",
            "$" + (data_obj['Total']['1'] / 100).round.to_s,
            "$" + (data_obj['Total']['2'] / 100).round.to_s,
            "$" + (data_obj['Total']['3'] / 100).round.to_s,
            "$" + (data_obj['Total']['Q1'] / 100).round.to_s,
            "$" + (data_obj['Total']['4'] / 100).round.to_s,
            "$" + (data_obj['Total']['5'] / 100).round.to_s,
            "$" + (data_obj['Total']['6'] / 100).round.to_s,
            "$" + (data_obj['Total']['Q2'] / 100).round.to_s,
            "$" + (data_obj['Total']['7'] / 100).round.to_s,
            "$" + (data_obj['Total']['8'] / 100).round.to_s,
            "$" + (data_obj['Total']['9'] / 100).round.to_s,
            "$" + (data_obj['Total']['Q3'] / 100).round.to_s,
            "$" + (data_obj['Total']['10'] / 100).round.to_s,
            "$" + (data_obj['Total']['11'] / 100).round.to_s,
            "$" + (data_obj['Total']['12'] / 100).round.to_s,
            "$" + (data_obj['Total']['Q4'] / 100).round.to_s,
            "$" + (data_obj['Total']['FY'] / 100).round.to_s
        ]
        csv << line
        csv << []
      end
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Advertiser", "Agency", "Team Member", "Budget", "Stage", "Probability", "Type", "Source", "Next Steps", "Start Date", "End Date", "Created Date", "Closed Date", "Close Reason"]
      all.each do |deal|
        agency_name = deal.agency.present? ? deal.agency.name : nil
        advertiser_name = deal.advertiser.present? ? deal.advertiser.name : nil
        stage_name = deal.stage.present? ? deal.stage.name : nil
        stage_probability = deal.stage.present? ? deal.stage.probability : nil
        budget = !deal.budget.nil? ? deal.budget/100.0 : nil
        member = deal.users.collect{|user| user.name}.join(";")
        csv << [deal.id, deal.name, advertiser_name, agency_name, member, budget, stage_name, stage_probability, get_option(deal, "Deal Type"), get_option(deal, "Deal Source"), deal.next_steps, deal.start_date, deal.end_date, deal.created_at.strftime("%Y-%m-%d"), deal.closed_at, get_option(deal, "Close Reason")]
      end
    end
  end

  def self.to_zip
    deals_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Advertiser", "Agency", "Team Member", "Budget", "Stage", "Probability", "Type", "Source", "Next Steps", "Start Date", "End Date", "Created Date", "Closed Date", "Close Reason"]
      all.each do |deal|
        agency_name = deal.agency.present? ? deal.agency.name : nil
        advertiser_name = deal.advertiser.present? ? deal.advertiser.name : nil
        stage_name = deal.stage.present? ? deal.stage.name : nil
        stage_probability = deal.stage.present? ? deal.stage.probability : nil
        budget = !deal.budget.nil? ? deal.budget/100.0 : nil
        member = deal.users.collect{|user| user.name}.join(";")
        csv << [deal.id, deal.name, advertiser_name, agency_name, member, budget, stage_name, stage_probability, get_option(deal, "Deal Type"), get_option(deal, "Deal Source"), deal.next_steps, deal.start_date, deal.end_date, deal.created_at.strftime("%Y-%m-%d"), deal.closed_at, get_option(deal, "Close Reason")]
      end
    end

    products_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Product", "Pricing Type", "Product Line", "Product Family", "Budget", "Period"]
      all.each do |deal|
        deal.deal_product_budgets.each do |deal_product_budget|
          budget = !deal_product_budget.budget.nil? ? deal_product_budget.budget/100.0 : nil
          product = deal_product_budget.deal_product.product
          product_name = ""
          pricing_type = ""
          product_family = ""
          product_line = ""
          if !product.nil?
            product_name = product.name
            pricing_type = get_option(product, "Pricing Type")
            product_line = get_option(product, "Product Line")
            product_family = get_option(product, "Product Family")
          end
		      csv << [deal.id, deal.name, product_name, pricing_type, product_line, product_family, budget, deal_product_budget.start_date.strftime("%B %Y")]
        end
      end
    end

    deal_stage_logs_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Stage", "Days in Stage", "Previous Stage", "Updated Date", "Updated By"]
      all.each do |deal|
        deal.deal_stage_logs.each do |deal_stage_log|
          stage_updator = deal_stage_log.stage_updator.name if !deal_stage_log.stage_updator.nil?
		      csv << [deal.id, deal.name, deal_stage_log.stage.name, deal_stage_log.active_wday, deal_stage_log.previous_stage ? deal_stage_log.previous_stage.name : "n/a", deal_stage_log.stage_updated_at, stage_updator]
        end
        stage_updator1 = deal.stage_updator.name if !deal.stage_updator.nil?
        active_wday = (deal.stage_updated_at.to_date..Time.current.to_date).count {|date| date.wday >= 1 && date.wday <= 5} if !deal.stage_updated_at.nil?
        csv << [deal.id, deal.name, deal.stage.name, active_wday, deal.previous_stage ? deal.previous_stage.name : "n/a", deal.stage_updated_at, stage_updator1]
      end
    end

    filestream = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry("deals-#{Date.today}.csv")
      zio.write deals_csv
      zio.put_next_entry("products-#{Date.today}.csv")
      zio.write products_csv
      zio.put_next_entry("deal-stages-#{Date.today}.csv")
      zio.write deal_stage_logs_csv
    end
    filestream.rewind
    filestream.read

  end

  def self.import(file, current_user)
    errors = []

    row_number = 0
    deal_type_field = current_user.company.fields.find_by_name('Deal Type')
    deal_source_field = current_user.company.fields.find_by_name('Deal Source')
    close_reason_field = current_user.company.fields.find_by_name("Close Reason")

    CSV.parse(file, headers: true) do |row|
      row_number += 1

      if row[0]
        begin
          deal = current_user.company.deals.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          error = { row: row_number, message: ["Deal ID #{row[0]} could not be found"] }
          errors << error
          next
        end
      end

      if row[1].nil? || row[1].blank?
        error = { row: row_number, message: ["Deal name can't be blank"] }
        errors << error
        next
      end

      if row[2].present?
        advertiser_type_id = Client.advertiser_type_id(current_user.company)
        advertisers = current_user.company.clients.by_type_id(advertiser_type_id).where('name ilike ?', row[2].strip)
        if advertisers.length > 1
          error = { row: row_number, message: ["Advertiser #{row[2]} matched more than one client record"] }
          errors << error
          next
        elsif advertisers.length == 0
          error = { row: row_number, message: ["Advertiser #{row[2]} could not be found"] }
          errors << error
          next
        else
          advertiser = advertisers.first
        end
      else
        error = { row: row_number, message: ["Advertiser can't be blank"] }
        errors << error
        next
      end

      if row[3].present?
        agency_type_id = Client.agency_type_id(current_user.company)
        agencies = current_user.company.clients.by_type_id(agency_type_id).where('name ilike ?', row[3].strip)
        if agencies.length > 1
          error = { row: row_number, message: ["Agency #{row[3]} matched more than one client record"] }
          errors << error
          next
        elsif agencies.length == 0
          error = { row: row_number, message: ["Agency #{row[3]} could not be found"] }
          errors << error
          next
        else
          agency = agencies.first
        end
      end

      if row[4].present?
        deal_type = deal_type_field.options.where('name ilike ?', row[4].strip).first
        unless deal_type
          error = { row: row_number, message: ["Deal Type #{row[4]} could not be found"] }
          errors << error
          next
        end
      else
        deal_type = nil
      end

      if row[5].present?
        deal_source = deal_source_field.options.where('name ilike ?', row[5].strip).first
        unless deal_source
          error = { row: row_number, message: ["Deal Source #{row[5]} could not be found"] }
          errors << error
          next
        end
      else
        deal_source = nil
      end

      start_date = nil
      if row[6].present?
        if !(row[7].present?)
          error = {row: row_number, message: ['End Date must be present if Start Date is set'] }
          errors << error
          next
        end
        begin
          start_date = Date.parse(row[6])
        rescue ArgumentError
          error = {row: row_number, message: ['Start Date must have valid date format DD/MM/YYYY'] }
          errors << error
          next
        end
      end

      end_date = nil
      if row[7].present?
        if !(row[6].present?)
          error = {row: row_number, message: ['Start Date must be present if End Date is set'] }
          errors << error
          next
        end
        begin
          end_date = Date.parse(row[7])
        rescue ArgumentError
          error = {row: row_number, message: ['End Date must have valid date format DD/MM/YYYY'] }
          errors << error
          next
        end
      end

      if (end_date && start_date) && start_date > end_date
        error = {row: row_number, message: ['Start Date must preceed End Date'] }
        errors << error
        next
      end

      if row[8].present?
        stage = current_user.company.stages.where('name ilike ?', row[8].strip).first
        unless stage
          error = { row: row_number, message: ["Stage #{row[8]} could not be found"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Stage can't be blank"] }
        errors << error
        next
      end

      deal_member_list = []
      if row[9].present?
        deal_members = row[9].split(';').map{|el| el.split('/') }

        deal_member_list_error = false

        deal_members.each do |deal_member|
          if deal_member[1].nil?
            error = { row: row_number, message: ["Deal Member #{deal_member[0]} does not have a share"] }
            errors << error
            deal_member_list_error = true
            break
          elsif user = current_user.company.users.where('email ilike ?', deal_member[0]).first
            deal_member_list << user
          else
            error = { row: row_number, message: ["Deal Member #{deal_member[0]} could not be found in the User list"] }
            errors << error
            deal_member_list_error = true
            break
          end
        end

        if deal_member_list_error
          next
        end
      else
        error = { row: row_number, message: ["Team can't be blank"] }
        errors << error
        next
      end

      if row[10].present?
        begin
          created_at = DateTime.parse(row[10])
        rescue ArgumentError
          error = {row: row_number, message: ['Deal Creation Date must be a valid datetime'] }
          errors << error
          next
        end
      end

      if row[11].present?
        begin
          closed_date = Date.parse(row[11])
        rescue ArgumentError
          error = {row: row_number, message: ['Deal Close Date must have valid date format DD/MM/YYYY'] }
          errors << error
          next
        end
      else
        closed_date = nil
      end

      if row[12].present?
        close_reason = close_reason_field.options.where('name ilike ?', row[12].strip).first
        unless close_reason
          error = { row: row_number, message: ["Close Reason #{row[12]} could not be found"] }
          errors << error
          next
        end
      else
        close_reason = nil
      end

      deal_contact_list = []
      if row[13].present?
        deal_contacts = row[13].split(';')

        deal_contact_list_error = false

        deal_contacts.each do |deal_contact|
          if contact = Contact.by_email(deal_contact, current_user.company_id).first
            deal_contact_list << contact
          else
            error = { row: row_number, message: ["Contact #{deal_contact} could not be found"] }
            errors << error
            deal_contact_list_error = true
            break
          end
        end

        if deal_contact_list_error
          next
        end
      end

      deal_params = {
        name: row[1].strip,
        advertiser: advertiser,
        agency: agency,
        start_date: start_date,
        end_date: end_date,
        stage: stage,
        updated_by: current_user.id,
        closed_at: closed_date
      }

      deal_params[:created_at] = created_at if created_at

      type_value_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: deal_type_field.id,
        option_id: (deal_type ? deal_type.id : nil),
        company_id: current_user.company.id
      }

      source_value_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: deal_source_field.id,
        option_id: (deal_source ? deal_source.id : nil),
        company_id: current_user.company.id
      }

      close_reason_params = {
        value_type: 'Option',
        subject_type: 'Deal',
        field_id: close_reason_field.id,
        option_id: (close_reason ? close_reason.id : nil),
        company_id: current_user.company.id
      }

      if !(deal.present?)
        deals = current_user.company.deals.where('name ilike ?', row[1].strip)
        if deals.length > 1
          error = { row: row_number, message: ["Deal name #{row[1]} matched more than one deal record"] }
          errors << error
          next
        end
        deal = deals.first
      end

      if deal.present?
        type_value_params[:subject_id] = deal.id
        source_value_params[:subject_id] = deal.id

        if deal_type_value = deal.values.where(field_id: deal_type_field).first
          type_value_params[:id] = deal_type_value.id
        end

        if deal_source_value = deal.values.where(field_id: deal_source_field).first
          source_value_params[:id] = deal_source_value.id
        end
      else
        deal = current_user.company.deals.new(created_by: current_user.id)
        deal_is_new = true
      end

      deal_params[:values_attributes] = [
        type_value_params,
        source_value_params,
        close_reason_params
      ]

      if deal.update_attributes(deal_params)
        deal.deal_members.delete_all if deal_is_new
        deal_member_list.each_with_index do |user, index|
          deal_member = deal.deal_members.find_or_initialize_by(user: user)
          deal_member.update(share: deal_members[index][1].to_i)
        end
        deal_contact_list.each do |contact|
          deal.deal_contacts.find_or_create_by(contact: contact)
        end
      else
        error = { row: row_number, message: deal.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end

  def update_stage
    self.previous_stage_id = self.stage_id_was
    self.stage_updated_at = updated_at
    self.stage_updated_by = updated_by
  end

  def log_stage
    if company.present? && stage_id_was.present? && stage_updated_by_was.present? && stage_updated_at_was.present?
      deal_stage_logs.create(
        company_id: company.id,
        stage_id: stage_id_was,
        previous_stage_id: previous_stage_id_was,
        stage_updated_by: stage_updated_by_was,
        stage_updated_at: stage_updated_at_was,
        active_wday: count_wday(stage_updated_at_was, stage_updated_at)
      )
    end
  end

  def update_close
    self.closed_at = updated_at if !stage.open?
    should_open = stage.open?
    if !stage.open? && stage.probability == 100
      self.deal_products.each do |deal_product|
        if deal_product.product.revenue_type != "Content-Fee"
          should_open = true
          deal_product.open = true
        else
          deal_product.open = false
        end
        deal_product.save
      end

      notification = company.notifications.find_by_name('Closed Won')
      if !notification.nil? && !notification.recipients.nil?
        recipients = notification.recipients.split(',').map(&:strip)
        if !recipients.nil? && recipients.length > 0
          subject = 'A '+(budget.nil? ? '$0' : ActiveSupport::NumberHelper.number_to_currency((budget/100.0).round, :precision => 0))+' deal for '+advertiser.name+' was just won!'
          UserMailer.close_email(recipients, subject, self).deliver_later(wait: 10.minutes, queue: "default")
        end
      end
    else
      self.deal_products.each do |deal_product|
        deal_product.open = stage.open
        deal_product.save
      end
      if !self.closed_at.nil? && stage.open?
        self.closed_at = nil
        if !self.fields.nil? && !self.values.nil?
          field = self.fields.find_by_name("Close Reason")
          close_reason = self.values.find_by_field_id(field.id) if !field.nil?
          close_reason.destroy if !close_reason.nil?
        end
      end
      notification = company.notifications.find_by_name('Stage Changed')
      if !notification.nil? && !notification.recipients.nil?
        recipients = notification.recipients.split(',').map(&:strip)
        if !recipients.nil? && recipients.length > 0
          subject = self.name + ' changed to ' + stage.name + ' - ' + stage.probability.to_s + '%'
          UserMailer.stage_changed_email(recipients, subject, self.id).deliver_later(wait: 10.minutes, queue: "default")
        end
      end      
    end
    self.open = should_open.to_s
  end

  def set_deal_status
    should_open = stage.open?
    if !stage.open? && stage.probability == 100
      deal_products.each do |deal_product|
        if deal_product.product.revenue_type != "Content-Fee"
          should_open = true
          deal_product.open = true
        else
          deal_product.open = false
        end
        deal_product.save
      end
    else
      deal_products.each do |deal_product|
        deal_product.open = stage.open
        deal_product.save
      end
    end
    self.open = should_open
    self.save
  end

  def generate_io
    if !stage.open? && stage.probability == 100
      io_param = {
          advertiser_id: self.advertiser_id,
          agency_id: self.agency_id,
          budget: self.budget / 100,
          start_date: self.start_date,
          end_date: self.end_date,
          name: self.name,
          io_number: self.id,
          external_io_number: nil,
          company_id: self.company_id,
          deal_id: self.id
      }
      if io = Io.create!(io_param)
        self.deal_members.each do |deal_member|
          if deal_member.user.present?
            io_member_param = {
                io_id: io.id,
                user_id: deal_member.user_id,
                share: deal_member.share,
                from_date: self.start_date,
                to_date: self.end_date,
            }
            IoMember.create!(io_member_param)
          end
        end

        self.deal_products.each do |deal_product|
          if deal_product.product.revenue_type == "Content-Fee"
            content_fee_param = {
                io_id: io.id,
                product_id: deal_product.product.id,
                budget: deal_product.budget / 100
            }
            content_fee = ContentFee.create(content_fee_param)
            deal_product.open = false
            deal_product.save
          end
        end
      end
    else
      if self.io.present?
        self.io.destroy
        self.deal_products.product_type_of("Content-Fee").update_all(open: true)
      end
    end

  end

  def wday_in_stage
    count_wday(stage_updated_at, Time.current) || 0
  end

  def wday_since_opened
    count_wday(created_at, Time.current) || 0
  end

  def count_wday(date1, date2)
    if !date1.nil?
      (date1.to_date..date2.to_date).count {|date| date.wday >= 1 && date.wday <= 5}
    end
  end

  def self.count_wday1(date1, date2)
    if !date1.nil?
      (date1.to_date..date2.to_date).count {|date| date.wday >= 1 && date.wday <= 5}
    end
  end

end
