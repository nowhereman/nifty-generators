class NiftyLayoutGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || 'application'
  end
  
  def manifest
    record do |m|
      m.directory 'app/views/layouts'
      m.directory 'public/stylesheets'
      m.directory 'app/helpers'
      
      if options[:haml]
        m.directory 'public/stylesheets/sass'
        m.template "layout.html.haml", "app/views/layouts/#{file_name}.html.haml"
        m.file     "stylesheet.sass",  "public/stylesheets/sass/#{file_name}.sass"
      else
        m.template "layout.html.erb", "app/views/layouts/#{file_name}.html.erb"
        m.file     "stylesheet.css",  "public/stylesheets/#{file_name}.css"
      end
      if options[:jquery]
        m.file 'application_helper.rb', 'app/helpers/application_helper.rb'# Modified application_helper.rb to be jQuery compatible
        m.file 'application.js', 'public/javascripts/application.js'# Create application.js to be jQuery compatible
      end
      m.file "helper.rb", "app/helpers/layout_helper.rb"
    end
  end
  
  def file_name
    @name.underscore
  end

  protected

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--haml", "Generate HAML for view, and SASS for stylesheet.") { |v| options[:haml] = v }
      opt.on("--jammit", "Use Jammit, an industrial strength asset packaging.") { |v| options[:jammit] = v }
      opt.on("--jquery", "Use jQuery unobtrusive goodness.") { |v| options[:jquery] = v }
    end

    def banner
      <<-EOS
Creates generic layout, stylesheet, and helper files.

USAGE: #{$0} #{spec.name} [layout_name]
EOS
    end
end
