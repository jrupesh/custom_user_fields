module CustomFieldsPlugin
  module Patches
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          after_validation :set_formula_values
        end
      end

      module InstanceMethods
        def set_formula_values
          return if !calculated_custom_field_values.any? && calulated_custom_fields_visible?
          logger.debug("Calculating Custom fields values formula")
          set_formula_custom_values
          update_related_issues
        end

        def calulated_custom_fields_visible?
          editable_custom_field_values(User.current).any? { |cv| calculated_custom_field_values.include?(cv) }
        end

        def calculated_custom_field_values
          @calculated_custom_field_values ||= custom_field_values.select do |value|
            value.custom_field.field_autocompute && !value.custom_field.field_formula.blank? &&
              ( value.custom_field.field_formula_applicable_tracker.any?{ |x| [0, tracker_id].include? x })
          end
        end

        # To check the performance ( May go in cyclic. Handle with a flag. )
        def update_related_issues
          return unless update_relations.any?
          logger.debug("Issue relation to update #{@update_relations}")
          self.relations.each do |relation|
            other_issue = relation.other_issue(self)
            relation_type = relation.relation_type_for(self)
            if @update_relations.include?(relation_type)
              other_issue.save
            end
          end
        end

        def update_relations
          @update_relations ||= []
        end

        def update_relations= (relationlist=[])
          update_relations ||=[]
          update_relations += relationlist
        end

        def set_formula_custom_values
          variable_hash = {}

          # Collect all the custom Values as a hash.
          custom_field_values.each do |field_value|
            begin
              next unless %w( int float list ).include?(field_value.custom_field.field_format)
              variable_hash["cf_#{field_value.custom_field.id}".to_sym] =  !field_value.value.blank? ? field_value.value.to_f : 0.0
            rescue Exception => e
              next
            end
          end
          logger.debug("Field has Custom formula : #{variable_hash}")

          # Get any Issue relations to be computed.
          related_issue_keywords  = []
          related_issue_types     = {}
          CustomField::OPERATORS.select do |k,v|
            if v[:type] == :relation
              related_issue_keywords << v[:op]
              related_issue_types[v[:op]] = v[:relation]
            end
          end

          # Compute for Custom Field values.
          calculated_custom_field_values.each do |field_value|
            # logger.debug("Custom field : #{field_value.custom_field.name}")
            # next if !field_value.custom_field.field_autocompute || field_value.custom_field.field_formula.blank? ||
            #   !field_value.custom_field.field_formula_applicable_tracker.any?{ |x| [0, tracker_id].include? x }
              logger.debug("Calculating for Custom field : #{field_value.custom_field.name}")

            # begin
              calculator = CustomFieldsPlugin::RedmineCalculator.calculator
              calculator.store(variable_hash)

              if related_issue_keywords.any? { |related| field_value.custom_field.field_formula.include? related }
                # For the related tasks, Get the field values.
                # self.load_relations(issues)
                any_relation = true
                related_issue_keywords.each do |kw|
                  v = []
                  if field_value.custom_field.field_formula =~ /#{kw}cf_(\d+)/
                    cf_field = $1.to_i

                    if kw == "RelatedSubTask."
                      children.each do |child|
                        child.custom_field_values.select{|p| v << p.value.to_f if p.custom_field.id == cf_field}
                      end
                    else
                      relations.each do |relation|
                        next if relation.relation_type != related_issue_types[kw]
                        relation.issue_to_id == id ?
                          relation.issue_from.custom_field_values.select{|p| v << p.value.to_f if p.custom_field.id == cf_field} :
                          relation.issue_to.custom_field_values.select{|p| v << p.value.to_f if p.custom_field.id == cf_field}
                      end
                    end
                    logger.debug("Relations value list : #{v.compact.flatten}")
                    if !v.compact.flatten.any?
                      any_relation = false
                      logger.debug("Relations value list : #{v.compact.flatten}")
                      break
                    end
                    logger.debug("Setting variable value : #{kw.gsub(".","")}cf_#{cf_field}")
                    calculator.store("#{kw}cf_#{cf_field}".gsub(".","").to_sym => v.compact.flatten )
                  end
                end
                next unless any_relation
              end

              calculated_value = calculator.evaluate(field_value.custom_field.field_formula.gsub(/{|}|\./, "") )
              logger.debug("Calculated value : #{calculated_value} ")

              # Check if the calculated value is changed from previous value.
              if calculated_value.to_f != field_value.value.to_f
                if field_value.custom_field.field_auto_update_relation.any?
                  update_relations= field_value.custom_field.field_auto_update_relation
                end

                case field_value.custom_field.field_format
                when 'int'
                  field_value.value = calculated_value.to_i
                when 'list'
                   # To check if the value exists in possible values.
                  # if calculated_value.to_s != field_value.value.to_s
                    if field_value.custom_field.possible_values.include?(calculated_value.to_i.to_s)
                      field_value.value = calculated_value.to_i.to_s
                    elsif field_value.custom_field.possible_values.include?(calculated_value.to_f.to_s)
                      field_value.value = calculated_value.to_f.to_s
                    else
                      logger.info("Computed Value #{calculated_value} not found in list values of Custom Field #{field_value.custom_field.name}")
                    end
                  # end
                else
                  field_value.value = calculated_value
                end
              end
              variable_hash["cf_#{field_value.custom_field.id}".to_sym] = field_value.value.to_f
            # rescue
            #   logger.error("Formula ERROR : Failed to compute value for #{field_value.custom_field.name} ")
            #   next
            # end
          end
        end
      end
    end
  end
end