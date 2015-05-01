module CustomFieldsPlugin
  module Hooks
    class UserFieldHook < Redmine::Hook::ViewListener
      def view_custom_fields_form_upper_box(param={})
        custom_field = param[:custom_field]
        f = param[:form]
        return "" unless custom_field.field_format == 'user'
        str = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, { :label => l(:label_group_of) },
              :onchange => 'if (this.value != "0") {$("#custom_field_role_of").find("option:first-child").prop("selected", true).end();}'
        puts "I am here.."
        return "<p>#{str}</p>".html_safe
      end
    end
  end
end