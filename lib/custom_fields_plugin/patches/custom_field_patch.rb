module CustomFieldsPlugin
  module Patches
		module CustomFieldPatch
	    def self.included(base)
	    	base.send(:include, InstanceMethods)
	      base.class_eval do
          unloadable
				end
			end

			module InstanceMethods
				def group_of
					return nil if field_format != 'user'
					format_store[:user_group]
				end

				def group_of=(arg)
					return if arg == '0'
					format_store[:user_group] = arg
				end
			end
		end
	end
end