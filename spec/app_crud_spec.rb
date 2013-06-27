require "spec_helper"
require "timeout"
require "net/http"
require "securerandom"

describe "App CRUD" do
  CHECK_DELAY = 0.5.freeze
  APP_START_TIMEOUT = 120.freeze
  APP_ROUTE_TIMEOUT = 5.freeze
  APP_SCALE_TIMEOUT = 60.freeze
  APP_DELETED_TIMEOUT = 60.freeze

  let(:admin_user) { AdminUser.from_env }
  let(:regular_user) { RegularUser.from_env }

  if org_name = ENV["NYET_ORGANIZATION_NAME"]
    before { @org = regular_user.find_organization_by_name(org_name) }
  else
    before { @org = admin_user.create_org(regular_user.user) }
    after { admin_user.delete_org }
  end

  # - `after`s are done in reverse order!
  # - failing in one after does not prevent execution of subsequent afters
  before { @space = regular_user.create_space(@org) }
  after { @space.delete!(:recursive => true) if @space }

  it "creates/updates/deletes an app" do
    begin
      monitoring.record_action(:create) do
        app_name = "crud"

        regular_user.clean_up_app_from_previous_run(app_name)
        @app = regular_user.create_app(@space, app_name)

        regular_user.clean_up_route_from_previous_run(app_name)
        @route = regular_user.create_route(@app, "#{app_name}-#{SecureRandom.uuid}")
      end

      monitoring.record_action(:read) do
        deploy_app(@app)
      end
      monitoring.record_action(:start) do
        start_app(@app)
      end
      monitoring.record_action(:app_routable) do
        check_app_routable(@route)
      end

      monitoring.record_action(:update) do
        scale_app(@app)
      end

      monitoring.record_action(:delete) do
        @route.delete!
        @app.delete!
        check_app_not_running(@route)
      end

      monitoring.record_metric("crud_app.health", 1)
    rescue => e
      monitoring.record_metric("crud_app.health", 0)
      raise e
    end
  end

  def deploy_app(app)
    app.upload(File.expand_path("../../apps/java/JavaTinyApp-1.0.war", __FILE__))
  end

  def start_app(app)
    staging_log = ""
    app.start!(true) do |url|
      app.stream_update_log(url) do |chunk|
        staging_log << chunk
      end if url
    end

    Timeout.timeout(APP_START_TIMEOUT) do
      check_app_started(app)
    end
  rescue
    puts "Staging app log:\n#{staging_log}"
    raise
  end

  def check_app_started(app)
    sleep(CHECK_DELAY) until app.running?
  rescue CFoundry::NotStaged
    sleep(CHECK_DELAY)
    retry
  end

  def check_app_routable(route)
    app_uri = URI("http://#{route.host}.#{route.domain.name}")
    routable = nil
    Timeout.timeout(APP_ROUTE_TIMEOUT) do
      routable = Net::HTTP.get(app_uri).match /^It just needed to be restarted!/
    end
    expect(routable).not_to be_nil
  end

  def scale_app(app)
    app.total_instances = 2
    app.update!

    Timeout.timeout(APP_SCALE_TIMEOUT) do
      sleep(CHECK_DELAY) until app.running?
    end
  end

  def check_app_not_running(route)
    app_uri = URI("http://#{route.name}")

    Timeout.timeout(APP_DELETED_TIMEOUT) do
      response = Net::HTTP.get_response(app_uri)
      puts "--- GET #{app_uri}: #{response.class}"

      while response.is_a?(Net::HTTPSuccess)
        puts "--- GET #{app_uri}: #{response.class}"
        sleep(CHECK_DELAY)
        response = Net::HTTP.get_response(app_uri)
      end
    end
  end
end
