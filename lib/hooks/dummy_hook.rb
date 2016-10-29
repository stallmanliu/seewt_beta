module Hooks
  class DummyHook
    def initialize(app, options)
      t = Time.now
      File.open("/opt/ISSC/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] lib/hooks/dummy_hook.rb:5, Hooks::DummyHook.initialize(app, options), app: " + app.inspect + ", options: " + options.inspect + ". " }
      
      @app = app
      @options = options
    end

    def call(env)
      @app.call(env)
    end
  end
end
