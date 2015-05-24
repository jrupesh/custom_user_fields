module CustomFieldsPlugin
  module Hooks
    class UserFieldHook < Redmine::Hook::ViewListener
      def view_custom_fields_form_upper_box(param={})

        custom_field = param[:custom_field]
        return unless custom_field.class.name == "IssueCustomField"

        f = param[:form]
        str = ""
        if custom_field.field_format == 'user'
          str = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, { :label => l(:label_group_of) },
                :onchange => 'if (this.value != "0") {$("#custom_field_role_of").find("option:first-child").prop("selected", true).end();}'
          return "<p>#{str}</p>".html_safe
        elsif %w( int float list ).include? custom_field.field_format
          str << "<p>"
          str << f.check_box(:field_autocompute, { :id => "cf_autocompute" ,:label => l(:label_auto_compute) })
          str << "</p>"

          str << "<p class='cfformula' style=#{custom_field.field_autocompute == false ? "display:none;" : "" } >"
          str << label_tag("fields","")
          str << select_tag("fields", options_for_select( CustomField.ForumlaSupportedCustomField.collect{|k| [ k[1], "cf_#{k[0]}" ]}),
                  :id=> 'cf_fields', :style => "width:55%" )
          str << select_tag("operators", options_for_select(CustomField.formula_group_option_select),
                  :id=> 'cf_operators', :style => "width:45%"  )
          str << "</p>"

          str << "<p id='cf_formula' class='cfformula' style=#{custom_field.field_autocompute == false ? "display:none;" : "" } >"
          str << f.text_area(:field_formula, :id=> 'cf_formula_area', :label => l(:label_formula) )
          str << "</p>"

          str << "<p id='cf_formula_tracker' class='cfformula' style=#{custom_field.field_autocompute == false ? "display:none;" : "" } >"
          str << f.select(:field_formula_applicable_tracker, options_for_select( [["All", 0]] + Tracker.sorted.collect {|t| [t.name, t.id] }, custom_field.field_formula_applicable_tracker),
                { :include_blank => false, :label => l(:label_formula_tracker) }, {:multiple => true })
          str << "</p>"

          str << "<p id='cf_formula_relation' class='cfformula' style=#{custom_field.field_autocompute == false ? "display:none;" : "" } >"
          str << f.select(:field_auto_update_relation, options_for_select( IssueRelation::TYPES.keys.collect {|t| [l(IssueRelation::TYPES[t][:sym_name]), t] },
                  custom_field.field_auto_update_relation),
                  { :include_blank => true, :label => l(:label_formula_relation) }, {:multiple => true })
          str << "</p>"

          str << javascript_tag("$('#cf_autocompute').change(function(){
            if (this.checked == true){ $('.cfformula').show(); }
            else{{ $('.cfformula').hide(); }} });")

        end
        return "#{str}".html_safe
      end
    end
  end
end