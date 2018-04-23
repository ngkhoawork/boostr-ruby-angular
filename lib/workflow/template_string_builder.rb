class Workflow::TemplateStringBuilder
  def initialize(text, params_hash = {})
    @text = text
    @params_hash = params_hash
  end

  def build
    CGI::unescapeHTML(Mustache.render(text, params_hash))
  end

  private

  attr_reader :text, :params_hash
end
