module Capybara
  module SaveAndOpenPage
    extend(self)

    def save_and_open_page(html)
      name="capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}.html"

      FileUtils.touch(name) unless File.exist?(name)

      tempfile = File.new(name,'w')
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close

      open_in_browser(tempfile.path)
    end

    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy::Browser.run(path)
    rescue LoadError
      warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
    end

    def rewrite_css_and_image_references(response_html) # :nodoc:
      return response_html unless Capybara.asset_root
      directories = Array.new
      Dir.new(Capybara.asset_root).entries.each do |name|
        directories << name if File.directory?(name) && !name.to_s[0].chr.eql?('.')
      end
      directories_string = directories*'|'
      response_html.gsub(/("|')\/(#{directories_string})/, '\1' + Capybara.asset_root + '/\2')
    end
  end
end
