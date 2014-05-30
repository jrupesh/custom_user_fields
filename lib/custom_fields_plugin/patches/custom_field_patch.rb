module CustomFieldsPlugin
  module Patches
		module CustomFieldPatch
	    def self.included(base)
	    	base.send(:include, InstanceMethods)
	      base.class_eval do
          unloadable
	      	alias_method_chain :possible_values_options, :role
				end
			end

      module InstanceMethods
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
			end
		end
	end
end