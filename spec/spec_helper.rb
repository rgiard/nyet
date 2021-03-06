require "bundler/setup"
require "support/monitoring"
require "support/dogapi_monitoring"
require "support/admin_user"
require "support/regular_user"
require "support/shared_space"
require "support/user_with_org"
require "support/test_app"
require "support/service"
require "support/cf_helpers"
require "blue-shell"

module MonitoringHelpers
  def monitoring
    @monitoring ||= (DogapiMonitoring.from_env || Monitoring.new)
  end
end

RSpec.configure do |config|
  config.include(MonitoringHelpers)
  config.include(BlueShell::Matchers)
end
