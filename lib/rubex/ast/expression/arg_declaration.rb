module Rubex
  module AST
    module Expression

      class ArgDeclaration < Base
        attr_reader :entry, :type, :data_hash

        def initialize data_hash
          @data_hash = data_hash
        end

        # FIXME: Support array of function pointers and array in arguments.
        def analyse_types local_scope, extern: false
          var, dtype, ident, ptr_level, value = fetch_data
          name, c_name = ident, Rubex::ARG_PREFIX + ident
          @type = Helpers.determine_dtype(dtype, ptr_level)
          value.analyse_types(local_scope) if value
          add_arg_to_symbol_table name, c_name, @type, value, extern, local_scope
        end

        private

        def add_arg_to_symbol_table name, c_name, type, value, extern, local_scope
          if !extern
            @entry = local_scope.add_arg(name: name, c_name: c_name, type: @type, value: value)
          end
        end

        def fetch_data
          var       = @data_hash[:variables][0]
          dtype     = @data_hash[:dtype]
          ident     = var[:ident]
          ptr_level = var[:ptr_level]
          value     = var[:value]

          [var, dtype, ident, ptr_level, value]
        end
      end # class ArgDeclaration
    end
  end
end