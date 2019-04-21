class Graphql::Variables

  class << self

    def process(variables)
      handle_variables_data(variables)
    end

    private

    def handle_variables_data(ambiguous_param)
      case ambiguous_param
      when String
        process_as_string(ambiguous_param)
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def process_as_string(ambiguous_param)
      return {} unless ambiguous_param.present?

      handle_variables_data(JSON.parse(ambiguous_param))
    end

  end

end
