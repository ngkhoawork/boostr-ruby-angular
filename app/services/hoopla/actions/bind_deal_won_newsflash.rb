class Hoopla::Actions::BindDealWonNewsflash < Hoopla::Actions::Base
  class << self
    def host
      "#{host_options[:host]}:#{host_options[:port]}"
    end

    def host_options
      @host_options ||= Rails.application.config.action_mailer.default_url_options
    end
  end

  DEAL_WON_NEWSFLASH = {
    name: 'Deal Won',
    icon_src: "#{host}/won-deal.png"
  }.freeze

  def perform
    deal_won_newsflash = find_deal_won_newsflash || create_deal_won_newsflash

    configuration.update(deal_won_newsflash_href: deal_won_newsflash[:href])
  end

  private

  def find_deal_won_newsflash
    api_caller
      .get_newsflashes(@options)
      .body
      .detect { |newsflash| newsflash[:name] == DEAL_WON_NEWSFLASH[:name] }
  end

  def create_deal_won_newsflash
    api_caller.create_newsflash(create_deal_won_newsflash_options).body
  end

  def create_deal_won_newsflash_options
    @options.merge(name: DEAL_WON_NEWSFLASH[:name], icon_src: DEAL_WON_NEWSFLASH[:icon_src])
  end
end
