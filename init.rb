require 'redmine'
require 'custom_fields_plugin/patches/user_format_patch'
require_dependency 'custom_field'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'custom_fields_plugin/hooks/custom_field_hook'
end

Redmine::Plugin.register :custom_user_fields do
  name 'Redmine custom user field plugin'
  author 'Rupesh J'
  description 'Add \'Group of\' to custom filed of user type.'
  version '1.0.0'
  author_url 'mailto:rupeshj@esi-group.com'
  requires_redmine :version_or_higher => '3.0.0'

  Rails.configuration.to_prepare do
    CustomField.send(:include, CustomFieldsPlugin::Patches::CustomFieldPatch)
    Redmine::FieldFormat::UserFormat.send(:include, CustomFieldsPlugin::Patches::UserFormatPatch)
  end
end
