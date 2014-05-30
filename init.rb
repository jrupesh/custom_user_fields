require 'redmine'

if Redmine::VERSION.to_s <= "2.5"
  require_dependency 'custom_fields_plugin/hooks/custom_field_hook'
  require_dependency 'custom_field'
  CustomField.send(:include, CustomFieldsPlugin::Patches::CustomFieldPatch)
end

Redmine::Plugin.register :custom_user_fields do
  name 'Redmine custom user field plugin'
  author 'Rupesh J'
  description 'Add \'Group of\' to custom filed of user type.'
  version '0.2.0'
  author_url 'mailto:rupeshj@esi-group.com'
  requires_redmine :version_or_higher => '2.0.0'
end
