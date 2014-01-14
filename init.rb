require 'redmine'

Redmine::Plugin.register :custom_user_fields do
  name 'Redmine custom user field plugin'
  author 'Rupesh J'
  description 'Add \'Role of\' and \'Group of\' to custom filed of user type.
  						Note : Initial \"Role of\" feature is forked from zhangfan'
  version '0.1.1'
  author_url 'mailto:rupeshj@esi-group.com'
  requires_redmine :version_or_higher => '2.0.0'
end

class UserFieldHook < Redmine::Hook::ViewListener

	def view_custom_fields_form_upper_box(param={})
		custom_field = param[:custom_field]
		return unless custom_field.field_format == 'user'
		f = param[:form]
		option_desc = l(:user_role_group_option)
		str = f.select :role_of, [['All', '0']] + Role.all.collect{|g| [g.to_s, g.id.to_s]}, {:label => l(:role_of)},
				 	:onchange => 'if (this.value != "0") {$("#custom_field_group_of").find("option:first-child").prop("selected", true).end();}'
		str1 = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, { :label => l(:group_of) },
					:onchange => 'if (this.value != "0") {$("#custom_field_role_of").find("option:first-child").prop("selected", true).end();}'

		"<p><em class='info'>#{option_desc}</em></p><p>#{str}</p><p>#{str1}</p>"
	end
	
end

RedmineApp::Application.config.after_initialize do

	class CustomField

		def role_of
			return nil if field_format != 'user'
			bt = read_attribute(:possible_values)
			return bt unless bt.is_a?(Array)
			eval(bt[0])["role"]
		end

		def role_of=(arg)
			return if arg == '0'
			self.possible_values = "{ \"role\" => #{arg} }" if field_format == 'user'
		end

		def group_of
			return nil if field_format != 'user'
			bt = read_attribute(:possible_values)
			return bt unless bt.is_a?(Array)
			eval(bt[0])["group"]
		end

		def group_of=(arg)
			return if arg == '0'
			self.possible_values = "{ \"group\" => #{arg} }" if field_format == 'user'
		end
		
		def possible_values_options_with_role(obj=nil)

			return possible_values_options_without_role(obj) unless field_format == 'user' && obj.respond_to?(:project) && obj.project

			if role_of.present? && role_of != '0'
				users = obj.project.users
				role = Role.find(role_of)
				users = users.select { |u| u.roles_for_project(obj.project).include?(role) } if role
				users.sort.collect{|u| [u.to_s, u.id.to_s]}
			elsif group_of.present? && group_of != '0'
				users = obj.project.users
				group = Group.find(group_of)
				users = group.users.select { |u| users.include?(u) } if group
				users.sort.collect{|u| [u.to_s, u.id.to_s]}					
			else
				possible_values_options_without_role(obj)
			end
		end
		
		alias_method_chain :possible_values_options, :role

	end if defined? CustomField
end
