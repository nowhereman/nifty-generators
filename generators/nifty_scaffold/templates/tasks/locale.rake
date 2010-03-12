namespace :locales  do
  desc "Merge locales files of config/locales/template/*.yml into config/locales/your_locale.yml"
  task :update => :environment do
      require 'ya2yaml'

      class Hash
        def deep_stringify_keys
          new_hash = {}
          self.each do |key, value|
            new_hash.merge!( key.to_s => (value.is_a?(Hash) ? value.deep_stringify_keys : value) )
          end
        end

        def to_safe_yaml
          method = respond_to?(:ya2yaml) ? :ya2yaml : :to_yaml
          string = deep_stringify_keys.send(method)
          string.gsub("!ruby/symbol ", ":").sub("---","").split("\n").map(&:rstrip).join("\n").strip
        end
      end
      
      locales = Dir["#{RAILS_ROOT}/config/locales/templates/*.{yml,yaml}"].map do |f|
          f = f.gsub("\\","/")# Windows fix
          File.basename(f,File.extname(f))
        end.reject { |l| !l.match(/^[^\.]+$/) }

      locales.each do |locale|
        standard_locale = "#{RAILS_ROOT}/config/locales/templates/#{locale}.yml"
        destination_locale = "#{RAILS_ROOT}/config/locales/#{locale}.yml"

        files = Dir["#{RAILS_ROOT}/config/locales/templates/*.#{locale}.{yml,yaml}"]
        merge_locale = YAML.load_file(standard_locale)

        # Merge keys inside standard_locale file
        files.each do |file|
          current_locale = YAML.load_file(file)
          merge_locale.deep_merge!current_locale
        end

        File.open(destination_locale, "w") do |file|
          file.write "# !!!WARNING!!!! This file is auto-generated from the files of 'config/locales/templates/*.yml'. Instead of editing this file,\n"
          file.write "# please edit the files in config/locales/templates/ then run 'rake locales:update' or './script/generate nifty_scaffold your_model'\n"
          file.write merge_locale.to_safe_yaml
        end
      end      
  end
end