require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Controle
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Brasilia"
    config.i18n.default_locale = :"pt-BR"
    config.i18n.locale = :"pt-BR"
  end
end
