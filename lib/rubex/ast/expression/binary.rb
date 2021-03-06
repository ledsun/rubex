module Rubex
  module AST
    module Expression
      # Binary expression Base class.
      class Binary < Base
        include Rubex::Helpers::NodeTypeMethods
        def initialize left, operator, right
          @left, @operator, @right = left, operator, right
          @subexprs = []
        end

        def analyse_types local_scope
          @left.analyse_types local_scope
          @right.analyse_types local_scope
          if type_of(@left).object? || type_of(@right).object?
            @left = @left.to_ruby_object
            @right = @right.to_ruby_object
            @has_temp = true
          end
          @type = Rubex::Helpers.result_type_for(type_of(@left), type_of(@right))
          @subexprs << @left
          @subexprs << @right
        end

        def generate_evaluation_code code, local_scope
          generate_and_dispose_subexprs(code, local_scope) do
            if @has_temp
              code << "#{@c_code} = rb_funcall(#{@left.c_code(local_scope)}," +
                "rb_intern(\"#{@operator}\")," +
                "1, #{@right.c_code(local_scope)});"
              code.nl
            else
              @c_code = "( #{@left.c_code(local_scope)} #{@operator} #{@right.c_code(local_scope)} )"
            end
          end
        end

        def c_code local_scope
          super + @c_code
        end

        def == other
          self.class == other.class && @type  == other.type &&
          @left == other.left  && @right == other.right &&
          @operator == other.operator
        end

        private

        def type_of expr
          t = expr.type
          return (t.c_function? ? t.type : t)
        end
      end
    end
  end
end
