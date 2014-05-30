module CustomFieldsPlugin
  module Hooks
    class UserFieldHook < Redmine::Hook::ViewListener
      def view_custom_fields_form_upper_box(param={})
        custom_field = param[:custom_field]
        return unless custom_field.field_format == 'user'
        f = param[:form]
        
        if Redmine::VERSION.to_s < "2.5"
          option_desc = l(:user_role_group_option)
          str = f.select :role_of, [['All', '0']] + Role.all.collect{|g| [g.to_s, g.id.to_s]}, {:label => l(:role_of)},
                :onchange => 'if (this.value != "0") {$("#custom_field_group_of").find("option:first-child").prop("selected", true).end();}'
          str1 = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, { :label => l(:group_of) },
                :onchange => 'if (this.value != "0") {$("#custom_field_role_of").find("option:first-child").prop("selected", true).end();}'

          return "<p><em class='info'>#{option_desc}</em></p><p>#{str}</p><p>#{str1}</p>"
        end

        str = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, { :label => l(:group_of) },
              :onchange => 'if (this.value != "0") {$("#custom_field_role_of").find("option:first-child").prop("selected", true).end();}'

        return "<p>#{str}</p>"
      end
    end
  end
end