class NoMatchIoMailer < ApplicationMailer
  default from: 'boostr <boostr@boostrcrm.com>'
  include Mailer::NoMatchIo
end
