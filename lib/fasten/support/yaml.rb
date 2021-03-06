require 'yaml'

module Fasten
  module Support
    module Yaml
      def load_yaml(path)
        items = YAML.safe_load(File.read(path)).each do |name, params|
          if params.is_a? String
            params = { after: params }
          elsif params.is_a? Hash
            transform_params(params)
          else
            params = {}
          end

          task name, params
        end

        log_info "Loaded #{items.count} tasks from #{path}"
      end

      def save_yaml(path)
        keys = %i[after shell]

        items = tasks.map do |task|
          data = task.to_h.select do |key, _val|
            keys.include? key
          end

          [task.name, data]
        end.to_h

        File.write path, items.to_yaml

        log_info "Loaded #{items.count} tasks into #{path}"
      end

      protected

      def transform_params(params)
        params.keys.each do |k|
          val = params[k]

          if val.is_a?(String) && (match = %r{^/(.+)/$}.match(val))
            val = Regexp.new(match[1])
          end

          params[k.to_sym] = val
          params.delete(k)
        end
      end
    end
  end
end
