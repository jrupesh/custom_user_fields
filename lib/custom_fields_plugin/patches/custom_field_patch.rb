module CustomFieldsPlugin
  module Patches
		module CustomFieldPatch

			OPERATORS = {
				"ADD" 							=> { :op => "+", :type => :maths },
				"SUBTRACT" 					=> { :op => "-", :type => :maths },
				"MULTIPLY" 					=> { :op => "*", :type => :maths },
				"DIVIDE" 						=> { :op => "/", :type => :maths },
				"LESS THAN" 				=> { :op => "<", :type => :logic },
				"GREATER THAN" 			=> { :op => ">", :type => :logic },
				"LESS THAN EQL" 		=> { :op => "<=", :type => :logic },
				"GREATER THAN EQL"	=> { :op => ">=", :type => :logic },
				"NOT EQUAL TO"			=> { :op => "<>", :type => :logic },
				"EQUAL"			 				=> { :op => "=", :type => :logic },
				"MAX"			 					=> { :op => "MAX", :type => :function },
				"MIN"			 					=> { :op => "MIN", :type => :function },
				"IF"			 					=> { :op => "IF", :type => :function },
				"NOT"			 					=> { :op => "NOT", :type => :function },
				"ROUND"			 				=> { :op => "ROUND", :type => :function },
				"ROUNDDOWN"			 		=> { :op => "ROUNDDOWN", :type => :function },
				"ROUNDUP"			 			=> { :op => "ROUNDUP", :type => :function },
				"Related"			 			=> { :op => "RelatedIssue.", :type => :relation, :relation => "relates" },
				"Sub Task"  	 			=> { :op => "RelatedSubTask.", :type => :relation, :relation => "subtask" }
        }.freeze

	    def self.included(base)
	    	base.extend(ClassMethods)
	    	base.send(:include, InstanceMethods)
	      base.class_eval do
          unloadable
          base.const_set('OPERATORS', OPERATORS)
				end
			end

      module ClassMethods
      	def ForumlaSupportedCustomField
      		IssueCustomField.where(:field_format => ["int", "float", "list"]).pluck(:id, :name)
      	end

        def formula_group_option_select
          CustomField::OPERATORS.collect { |k,v| [k, v[:op]] }
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

				def field_autocompute
					return false unless %w( int float list ).include? field_format
					format_store[:field_autocompute].nil? ? false : (format_store[:field_autocompute] == "1" || format_store[:field_autocompute] == true)
				end

				def field_autocompute=(arg)
					return if arg == '0'
					format_store[:field_autocompute] = arg
				end

				def field_formula
					return "" unless %w( int float list ).include? field_format
					format_store[:field_formula]
				end

				def field_formula=(arg)
					return if arg == '0'
					format_store[:field_formula] = arg
				end

				def field_formula_applicable_tracker
					return [] unless %w( int float list ).include? field_format
					format_store[:field_formula_applicable_tracker].nil? ? [0] : format_store[:field_formula_applicable_tracker].map(&:to_i)
				end

				def field_formula_applicable_tracker=(arg)
					format_store[:field_formula_applicable_tracker] = arg.reject(&:blank?)
				end

				def field_auto_update_relation
					return [] unless %w( int float list ).include? field_format
					format_store[:field_auto_update_relation].nil? ? [] : format_store[:field_auto_update_relation]
				end

				def field_auto_update_relation=(arg)
					format_store[:field_auto_update_relation] = arg.reject(&:blank?)
				end
			end
		end
	end
end