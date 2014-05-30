module CustomFieldsPlugin
  module Patches
		module UserFormatPatch
	    def self.included(base)
	    	base.send(:include, InstanceMethods)
	      base.class_eval do
          unloadable
      		alias_method_chain :possible_values_options, :group
				end
			end

			module InstanceMethods

				def possible_values_options_with_group(custom_field, obj=nil)
					return possible_values_options_without_group(custom_field, obj) unless custom_field.field_format == 'user' && obj.respond_to?(:project)

					if custom_field.group_of.present? && custom_field.group_of != '0'
						users = obj.project.users
						group = Group.find(custom_field.group_of)
            if !group.nil?
  						users = group.users.select { |u| users.include?(u) } 
  						return users.sort.collect{ |u| [u.to_s, u.id.to_s] }
            end
					end
					possible_values_options_without_group(custom_field, obj)
				end
			end
		end
	end
end

Redmine::FieldFormat::UserFormat.send(:include, CustomFieldsPlugin::Patches::UserFormatPatch)