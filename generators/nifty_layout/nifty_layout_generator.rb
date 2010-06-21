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
        if options[:external_source] && File.exist?( File.join(options[:external_source], "layout.html.erb") )
          m.template([ File.join(options[:external_source], "layout.html.erb"), { :full_path => true } ], "app/views/layouts/#{file_name}.html.erb")
        else
          m.template "layout.html.erb", "app/views/layouts/#{file_name}.html.erb"
        end
        m.file     "stylesheet.css",  "public/stylesheets/#{file_name}.css"
      end
      if options[:jquery]
        m.file 'application_helper.rb', 'app/helpers/application_helper.rb'# Modified application_helper.rb to be jQuery compatible
        m.file 'application.js', 'public/javascripts/application.js'# Create an application.js compatible with jQuery
      end
      m.file "helper.rb", "app/helpers/layout_helper.rb"
    end
  end

  def file_name
    @name.underscore
  end

  # Return the full path from the source root for the given path.
  # Example for source_root = '/source':
  #   source_path('some/path.rb') == '/source/some/path.rb'
  #
  # Or an external path if the option :full path is set.
  # Example :
  #   source_path('/my_external/path.rb', :full_path => true) == '/my_external/path.rb'
  #
  # The given path may include a colon ':' character to indicate that
  # the file belongs to another generator.  This notation allows any
  # generator to borrow files from another.  Example:
  #   source_path('model:fixture.yml') = '/model/source/path/fixture.yml'
  def source_path(relative_source)
    source_options = {}
    if relative_source.respond_to?(:extract_options!)
      source_options = relative_source.extract_options!
      relative_source = relative_source.first #if relative_source.length == 1
    end

    # Check whether we're referring to another generator's file.
    name, path = relative_source.split(':', 2)
   
    if source_options[:full_path]
        relative_source

    # If not, return the full path to our source file if it isn't a full path.
    elsif path.nil?
      File.join(source_root, name)

    # Otherwise, ask our referral for the file.
    else
      # FIXME: this is broken, though almost always true.  Others'
      # source_root are not necessarily the templates dir.
      File.join(self.class.lookup(name).path, 'templates', path)
    end
  end

  protected

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--authlogic", "Use Authlogic for authentication.") { |v| options[:authlogic] = v }
      opt.on("--formtastic", "Include Formtastic stylesheet.") { |v| options[:formtastic] = v }
      opt.on("--haml", "Generate HAML for view, and SASS for stylesheet.") { |v| options[:haml] = v }
      opt.on("--jammit", "Use Jammit, an industrial strength asset packaging.") { |v| options[:jammit] = v }
      opt.on("--jquery", "Use jQuery unobtrusive goodness.") { |v| options[:jquery] = v }
      opt.on("--external-source=REQUIRED", "Set an external source path to add custom templates.") { |v| options[:external_source] = v }
    end

    def banner
      <<-EOS
Creates generic layout, stylesheet, and helper files.

USAGE: #{$0} #{spec.name} [layout_name]
EOS
    end
end
