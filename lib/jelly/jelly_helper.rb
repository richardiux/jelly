module JellyHelper
  include Jelly::Common

  def application_jelly_files(jelly_files_path_from_javascripts = '', rails_root = RAILS_ROOT)
    rails_root = File.expand_path(rails_root)
    (
      Dir[File.expand_path("#{rails_root}/public/javascripts/#{jelly_files_path_from_javascripts}/components/**/*.js")] +
      Dir[File.expand_path("#{rails_root}/public/javascripts/#{jelly_files_path_from_javascripts}/pages/**/*.js")]
    ).map do |path|
      path.gsub("#{rails_root}/public/javascripts/", "").gsub(/\.js$/, "")
    end
  end

  def spread_jelly
    attach_javascript_component("Jelly.Location")
    attach_javascript_component("Jelly.Page", controller.controller_path.camelcase, controller.action_name)
    javascript_tag <<-JS
      #{window_token}
      #{attach_javascript_component(jelly_attachments)}
    JS
  end
  
  def window_token
    "window._token = '#{form_authenticity_token}';"
  end

  def window_token_javascript_tag
    javascript_tag(window_token)
  end
  
  def attach_javascript_component(*components)
    components = [components].flatten
    <<-JS
    $(document).ready(function() {
      Jelly.attach.apply(Jelly, #{components.to_json});
    });
    JS
  end

  def attach_javascript_component_javascript_tag(*components)    
    javascript_tag (attach_javascript_component(components))
  end

  def clear_jelly_attached
    jelly_attachments.clear
  end

  def attach_javascript_component(component_name, *args)
    key = jelly_attachment_hash(component_name, *args)
    unless jelly_attachments.include? key
      jelly_attachments << key
    end
  end

  def attach_javascript_component_on_ready(component_name, *args)
    warn "attach_javascript_component_on_ready is deprecated since attach_javascript_component adds components to be attached in a $(document).ready block\n#{puts caller.join("\n\t")}"
    attach_javascript_component(component_name, *args)
  end

  def jelly_attachments
    @jelly_attachments ||= []
  end

end