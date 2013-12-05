require 'redmine'

Redmine::Plugin.register :custom_user_fields do
  name 'Redmine custom user field plugin'
  author 'Zhang Fan'
  description 'Add \'Role of\' to custom filed of user type.'
  version '0.1.0'
  url 'http://web.4399.com'
  author_url 'mailto:zhangfan@4399.net'
  requires_redmine :version_or_higher => '2.0.0'
end

class UserFieldHook < Redmine::Hook::ViewListener

	def view_custom_fields_form_upper_box(param={})
		custom_field = param[:custom_field]
		return unless custom_field.field_format == 'user'
		f = param[:form]
		str = f.select :role_of, [['All', '0']] + Role.all.collect{|g| [g.to_s, g.id.to_s]}, :label => 'Role of'
		str1 = f.select :group_of, [['None', '0']] + Group.all.collect{|g| [g.to_s, g.id.to_s]}, :label => 'Group of'
		"<p>#{str}</p><p>#{str1}</p>"
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
			self.possible_values = "{ \"role\" => #{arg} }" if field_format == 'user'
		end

		def group_of
			return nil if field_format != 'user'
			bt = read_attribute(:possible_values)
			return bt unless bt.is_a?(Array)
			eval(bt[0])["group"]
		end

		def group_of=(arg)
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
