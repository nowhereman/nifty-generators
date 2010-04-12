class NiftyScaffoldGenerator < Rails::Generator::Base
  attr_accessor :name, :attributes, :controller_actions

  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.empty?

    @name = @args.first
    @controller_actions = []
    @attributes = []

    @args[1..-1].each do |arg|
      if arg == '!'
        options[:invert] = true
      elsif arg.include? ':'
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":"))
      else
        @controller_actions << arg
        @controller_actions << 'create' if arg == 'new'
        @controller_actions << 'update' if arg == 'edit'
        @controller_actions << 'delete' if arg == 'destroy'
      end
    end

    @controller_actions.uniq!
    @attributes.uniq!

    if options[:invert] || @controller_actions.empty?
      @controller_actions = all_actions - @controller_actions
    end

    if @attributes.empty?
      options[:skip_model] = true # default to skipping model if no attributes passed
      if model_exists?
        model_columns_for_attributes.each do |column|
          @attributes << Rails::Generator::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new('name', 'string')
      end
    end
  end

  def manifest
    record do |m|
      m.directory "config/locales/templates"
      locales = (options[:multilanguage]) ? all_locales : [ I18n.default_locale ]

      locales.each do |locale|
        unless File.exist? destination_path("config/locales/#{locale}.yml")
          FileUtils.cp(source_path("locales/#{locale}.yml"), destination_path("config/locales/#{locale}.yml"))
        end

        m.template "locales/template.#{locale}.yml", "config/locales/templates/#{singular_name}.#{locale}.yml"
      end

      unless options[:skip_model]
        m.directory "app/models"
        m.template "model.rb", "app/models/#{singular_name}.rb"
        unless options[:skip_migration]
          m.migration_template "migration.rb", "db/migrate", :migration_file_name => "create_#{plural_name}"
        end

        if rspec?
          m.directory "spec/models"
          m.template "tests/#{test_framework}/model.rb", "spec/models/#{singular_name}_spec.rb"
          if options[:make_fixture]
            m.directory "spec/fixtures"
            m.template "fixtures.yml", "spec/fixtures/#{plural_name}.yml"
          end
        else
          m.directory "test/unit"
          m.template "tests/#{test_framework}/model.rb", "test/unit/#{singular_name}_test.rb"
          if options[:make_fixture]
            m.directory "test/fixtures"
            m.template "fixtures.yml", "test/fixtures/#{plural_name}.yml"
          end
        end
      end

      unless options[:skip_controller]
        m.directory "app/controllers"
        if options[:inherited_resources]
          m.template "inherited_resources_controller.rb", "app/controllers/#{plural_name}_controller.rb"
        else
          m.template "controller.rb", "app/controllers/#{plural_name}_controller.rb"
        end

        m.directory "app/helpers"
        m.template "helper.rb", "app/helpers/#{plural_name}_helper.rb"

        m.directory "app/views/#{plural_name}"
        controller_actions.each do |action|
          if options[:jquery] && [:new, :create, :edit, :update, :destroy].include?(action.to_sym)
            m.template "views/#{view_language}/#{action}.js.#{view_language}", "app/views/#{plural_name}/#{action}.js.#{view_language}"
          end
          m.template "views/#{view_language}/delete.html.#{view_language}", "app/views/#{plural_name}/delete.html.#{view_language}" if action == 'destroy'
          if File.exist? source_path("views/#{view_language}/#{action}.html.#{view_language}")
            m.template "views/#{view_language}/_model.html.#{view_language}", "app/views/#{plural_name}/_#{singular_name}.html.#{view_language}" if action == 'index'
            m.template "views/#{view_language}/#{action}.html.#{view_language}", "app/views/#{plural_name}/#{action}.html.#{view_language}"
          end
        end

        if form_partial?
          if options[:formtastic]
            m.template "views/#{view_language}/_formtastic.html.#{view_language}", "app/views/#{plural_name}/_form.html.#{view_language}"
          else
            m.template "views/#{view_language}/_form.html.#{view_language}", "app/views/#{plural_name}/_form.html.#{view_language}"
          end
        end

        m.route_resources plural_name

        if rspec?
          m.directory "spec/controllers"
          rspec_controller_template = rspec_mocha_mocks? ? "controller_mocha_mocks.rb" : "controller_rspec_mocks.rb"
          m.template "tests/#{test_framework}/#{rspec_controller_template}",
            "spec/controllers/#{plural_name}_controller_spec.rb"
        else
          m.directory "test/functional"
          m.template "tests/#{test_framework}/controller.rb", "test/functional/#{plural_name}_controller_test.rb"
        end
      end
    end
  end

  def form_partial?
    actions? :new, :edit
  end

  def all_actions
    %w[index show new create edit update destroy delete]
  end

  def all_locales
    Dir["#{source_path('locales')}/*.{yml,yaml}"].reject { |f| !f.match(/^.+\/[^\.]+\.(yml|yaml)$/) }.map! { |l| l.gsub(/^.+\/(.+)\.(yml|yaml)$/,'\1') }
  end

  def action?(name)
    controller_actions.include? name.to_s
  end

  def actions?(*names)
    names.all? { |n| action? n.to_s }
  end

  def singular_name
    name.underscore
  end

  def plural_name
    name.underscore.pluralize
  end

  def class_name
    name.camelize
  end

  def plural_class_name
    plural_name.camelize
  end

  def controller_methods(dir_name)
    controller_actions.map do |action|
      read_template("#{dir_name}/#{action}.rb")
    end.join("  \n").strip
  end

  def render_form
    if form_partial?
      if options[:haml]
        "= render :partial => 'form'"
      else
        "<%= render :partial => 'form' %>"
      end
    else
      read_template("views/#{view_language}/_form.html.#{view_language}")
    end
  end

  def items_path(suffix = 'path')
    if action? :index
      "#{plural_name}_#{suffix}"
    else
      "root_#{suffix}"
    end
  end

  def item_path(suffix = 'path')
    if action? :show
      "@#{singular_name}"
    else
      items_path(suffix)
    end
  end

  def item_path_for_spec(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns[:#{singular_name}])"
    else
      items_path(suffix)
    end
  end

  def item_path_for_test(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns(:#{singular_name}))"
    else
      items_path(suffix)
    end
  end

  def model_columns_for_attributes
    class_name.constantize.columns.reject do |column|
      column.name.to_s =~ /^(id|created_at|updated_at)$/
    end
  end

  def rspec?
    test_framework == :rspec
  end


  def rspec_mocha_mocks?
    rspec_mock_with == :mocha
  end

  def after_generate
    `./script/generate hobo_migration create_#{plural_name} --default-name --migrate` if options[:hobofields]
    
    m = Rails::Generator::Commands::Create.new(self)
    #Replace route of the controller, in config/routes.rb
    replace_with("config/routes.rb","map.resources :#{plural_name}","  map.resources :#{plural_name}, :member => { :delete => :get }") if controller_actions.include?('destroy')

    locales = (options[:multilanguage]) ? all_locales : [ I18n.default_locale ]

    locales.each do |locale|
      m.template "locales/#{locale}.yml", "config/locales/templates/#{locale}.yml"
      files = Dir["#{source_path('locales')}/*.#{locale}.yml"] - [source_path("locales/template.#{locale}.yml")]
      files.each do |file|
        file = file.gsub("\\","/")# Windows fix
        file_name = File.basename(file)
        m.template "locales/#{file_name}", "config/locales/templates/#{file_name}"
      end
    end

    m.file('tasks/locale.rake', 'lib/tasks/locale.rake')
   `rake locales:update`
  end

  protected

  def view_language
    options[:haml] ? 'haml' : 'erb'
  end

  def test_framework
    options[:test_framework] ||= default_test_framework
  end


  def rspec_mock_with
    options[:rspec_mock_with] ||= :mocha
  end

  def default_test_framework
    File.exist?(destination_path("spec")) ? :rspec : :testunit
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--skip-timestamps", "Don't add timestamps to migration file.") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--make-fixture", "Only generate fixture file for model if requested.") { |v| options[:make_fixture] = v }
    opt.on("--invert", "Generate all controller actions except these mentioned.") { |v| options[:invert] = v }
    opt.on("--declarative-authorization", "Use Declarative Authorization for authorization.") { |v| options[:declarative_authorization] = v }
    opt.on("--jquery", "Use jQuery unobtrusive goodness.") { |v| options[:jquery] = v }
    opt.on("--multilanguage", "Generate multilanguage files") { |v| options[:multilanguage] = v }
    opt.on("--haml", "Generate HAML views instead of ERB.") { |v| options[:haml] = v }
    opt.on("--hobofields", "Rich field types and migration-generator.") do |v|
      options[:hobofields] = v
      options[:skip_migration] = v if v
    end
    opt.on("--inherited-resources", "Generate inherited-resources controller instead of conventional.") { |v| options[:inherited_resources] = v }
    opt.on("--will-paginate", "Generate will-paginate code.") { |v| options[:will_paginate] = v }
    opt.on("--formtastic", "Generate formtastic forms.") { |v| options[:formtastic] = v }
    opt.on("--testunit", "Use test/unit for test files.") { options[:test_framework] = :testunit }
    opt.on("--rspec", "Use RSpec for test files.") { options[:test_framework] = :rspec }
    opt.on("--rspecmocks", "Use RSpec for test files.") { options[:rspec_mock_with] = :rspec }
    opt.on("--shoulda", "Use Shoulda for test files.") { options[:test_framework] = :shoulda }
  end

  # is there a better way to do this? Perhaps with const_defined?
  def model_exists?
    File.exist? destination_path("app/models/#{singular_name}.rb")
  end

  def read_template(relative_path)
    File.exist?(source_path(relative_path)) ?
      ERB.new(File.read(source_path(relative_path)), nil, '-').result(binding) :
      ""
  end

  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end

  def replace_with(file, pattern, line)
    regex = pattern ? "\s*#{Regexp.escape(pattern)}\s*" : "(class|module) .+"

    gsub_file file, /^#{regex}$/ do |match|
      line
    end
  end


  def banner
    <<-EOS
Creates a controller and optional model given the name, actions, and attributes.

USAGE: #{$0} #{spec.name} ModelName [controller_actions and model:attributes] [options]
    EOS
  end
end
