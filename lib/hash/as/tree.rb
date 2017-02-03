require 'to_proc/all'

class Hash
  module As
    module Tree
      refine Hash do
        def traverse
          return to_enum(__method__) unless block_given?

          nodes = Queue.new
          nodes.push Node.new value: self

          until nodes.empty?
            current_node = nodes.pop
            yield current_node
            current_node.children.each &[nodes, :push]
          end
        end

        def rewrite
          nodes, root_node = Queue.new, (Node.new value: self)
          nodes.push root_node

          until nodes.empty?
            passed_node = nodes.pop
            returned_node = yield passed_node

            if passed_node == returned_node
              passed_node.children.each &[nodes, :push]
            else
              if parent = passed_node.parent
                parent.value.delete passed_node.key
                parent.value[returned_node.key] = returned_node.value
              end
              returned_node.children.each &[nodes, :push]
            end
          end

          root_node.to_h
        end
      end

      class Node
        def initialize value: nil, key: nil, parent: nil
          @value, @key, @parent = value, key, parent
        end
        attr_accessor :value, :key, :parent

        def to_h
          if key
            if value.is_a? Hash
              { key => children.map(&:to_h).reduce(&:merge) }
            else
              { key => value }
            end
          else
            children.map(&:to_h).reduce(&:merge)
          end
        end

        def with **kwargs
          Node.new \
            value:  (kwargs[:value] or value),
            key:    (kwargs[:key] or key),
            parent: (kwargs[:parent] or parent)
        end

        def children
          if value.is_a? Hash
            value.map do |key, value|
              Node.new value: value, key: key, parent: self
            end
          else
            []
          end
        end
      end
    end
  end
end
