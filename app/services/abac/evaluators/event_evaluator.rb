module Abac
  module Evaluators
    class EventEvaluator < BaseEvaluator
      def evaluate?(user, resource, scope)
        case scope
        when "personal"
          resource.creator == user || resource.creator.nil?
        when "any"
          true
        else
          false
        end
      end
    end
  end
end