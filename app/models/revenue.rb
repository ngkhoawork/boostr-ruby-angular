class Revenue < ActiveRecord::Base
  belongs_to :company
  belongs_to :client, touch: true
  belongs_to :user
  belongs_to :product

  scope :for_time_period, -> (start_date, end_date) { where('revenues.start_date <= ? AND revenues.end_date >= ?', end_date, start_date) }

  validates :company_id, :order_number, :line_number, :ad_server, :start_date, :end_date, presence: true
  validate :start_date_is_before_end_date

  before_save :set_daily_budget, :set_alert

  def self.import(file, company_id)
    errors = []
    row_number = 0
    CSV.parse(file, headers: true) do |row|
      row_number += 1

      unless user = User.where(email: row[14], company_id: company_id).first
        error = { row: row_number, message: ['Sales Rep could not be found'] }
        errors << error
        next
      end

      unless client = Client.where(id: row[13], company_id: company_id).first
        error = { row: row_number, message: ['Client could not be found'] }
        errors << error
        next
      end

      unless product = Product.where(id: row[15], company_id: company_id).first
        error = { row: row_number, message: ['Product could not be found'] }
        errors << error
        next
      end

      find_params = {
        company_id: company_id,
        order_number: row[0],
        line_number: row[1],
        ad_server: row[2]
      }

      create_params = {
        quantity: numeric(row[3]).to_i,
        price: numeric(row[4]).to_f * 100,
        price_type: row[5],
        delivered: numeric(row[6]).to_i,
        remaining: numeric(row[7]).to_i,
        budget: numeric(row[8]).to_i,
        budget_remaining: numeric(row[9]).to_i,
        start_date: (Chronic.parse(row[10])),
        end_date: (Chronic.parse(row[11])),
        client_id: client.id,
        user_id: user.id,
        product_id: product.id,
        comment: row[16]
      }

      revenue = Revenue.find_or_initialize_by(find_params)
      unless revenue.update_attributes(create_params)
        error = { row: row_number, message: revenue.errors.full_messages }
        errors << error
      end
    end
    set_alerts(company_id)
    errors
  end

  def self.numeric(value)
    if value.nil?
      0
    else
      value.gsub(/[^0-9\.\-']/, '')
    end
  end

  def client_name
    client.name if client.present?
  end

  def user_name
    user.name if user.present?
  end

  def product_name
    product.name if product.present?
  end

  def set_daily_budget
    self.daily_budget = budget.to_f / (end_date.to_date - start_date.to_date + 1).to_i * 100
  end

  def daily_budget
    read_attribute(:daily_budget)/100.0
  end

  def sum_budget
    @sum_budget
  end

  def add_sum_budget(other_budget)
    @sum_budget += other_budget
  end

  def sum_period_budget
    @sum_period_budget
  end

  def add_sum_period_budget(other_period_budget)
    @sum_period_budget += other_period_budget
  end

  def period_budget
    @period_budget
  end

  def set_period_budget(sd, ed)
    if self.start_date < sd
      sdate = sd
    else
      sdate = self.start_date
    end
    if self.end_date > ed
      edate = ed
    else
      edate = self.end_date
    end
    @period_budget = (daily_budget*(edate.to_date-sdate.to_date+1)).round
    @sum_period_budget = @period_budget
    @sum_budget = self.budget
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        client: {
          only: [:id, :name],
          include: [:client_members]
        }},
      methods: [:client_name, :user_name, :product_name, :period_budget, :sum_budget, :sum_period_budget]
    ))
  end

  def start_date_is_before_end_date
    return unless start_date && end_date

    errors.add(:start_date, "is after end date") if start_date > end_date
  end

  def set_alert
    if !budget.nil? && !budget_remaining.nil?
      if budget > 0 && start_date < DateTime.now && DateTime.now < end_date
        self.run_rate = ((budget-budget_remaining)/(DateTime.now.to_date-start_date.to_date+1))*100.0
        if self.run_rate != 0
          self.remaining_day = budget_remaining/(self.run_rate/100.0)
          self.balance = ((end_date.to_date-DateTime.now.to_date+1)-self.remaining_day)*(self.run_rate/100.0)
        else
          self.remaining_day = 0
          self.balance = 0
        end
      else
        self.run_rate = 0
        self.remaining_day = 0
        self.balance = 0
      end
      self.last_alert_at = DateTime.now
    end
  end

  def self.set_alerts(company_id)
    User.where(company_id: company_id).update_all(pos_balance_cnt: 0, neg_balance_cnt: 0, pos_balance: 0, neg_balance: 0, pos_balance_l_cnt: 0, neg_balance_l_cnt: 0, pos_balance_l: 0, neg_balance_l: 0, last_alert_at: DateTime.now)
    where(company_id: company_id).each do |r|
      if r.last_alert_at.nil? || r.last_alert_at.to_date < DateTime.now.to_date
        r.set_alert
      end
      r.client.client_members.each do |cm|
        if cm.share > 0
          u = cm.user
          if r.balance > 0
            u.pos_balance_cnt += 1
            u.pos_balance += r.balance*cm.share/100
          elsif r.balance < 0
            u.neg_balance_cnt += 1
            u.neg_balance += r.balance*cm.share/100
          end
          u.pos_balance_l_cnt = u.pos_balance_cnt
          u.pos_balance_l = u.pos_balance
          u.neg_balance_l_cnt = u.neg_balance_cnt
          u.neg_balance_l = u.neg_balance
          u.last_alert_at = DateTime.now
          u.save
        end
      end
    end
    Team.where(company_id: company_id).where.not(leader_id: nil).each do |t|
      l = t.leader
      if !l.nil?
        ps = []
        t.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance > 0").each do |r|
                ps += [r] if !ps.include?(r)
              end
            end
          end
        end
        t.all_leaders.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance > 0").each do |r|
                ps += [r] if !ps.include?(r)
              end
            end
          end
        end
        l.pos_balance_l_cnt = ps.length
        ns = []
        t.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance < 0").each do |r|
                ns += [r] if !ns.include?(r)
              end
            end
          end
        end
        t.all_leaders.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance < 0").each do |r|
                ns += [r] if !ns.include?(r)
              end
            end
          end
        end
        l.neg_balance_l_cnt = ns.length
        l.pos_balance_l = t.sum_pos_balance
        l.neg_balance_l = t.sum_neg_balance
        l.last_alert_at = DateTime.now
        l.save
      end
    end
  end

end
