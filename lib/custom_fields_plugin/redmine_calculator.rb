module CustomFieldsPlugin
  module RedmineCalculator

    def self.calculator
      calculator = Dentaku::Calculator.new

      calculator.add_function(
        name: :max,
        type: :numeric,
        signature: [:arguments],
        body: ->(*args) { args.flatten.max }
      )

      calculator.add_function(
        name: :min,
        type: :numeric,
        signature: [:arguments],
        body: ->(*args) { args.flatten.min }
      )

      calculator
    end
  end
end