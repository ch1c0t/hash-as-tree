require 'to_proc/all'

class Hash
  module As
    module Tree
      COMBINATOR = -> hash, key do
        hash[key] = Hash.new &COMBINATOR
      end

      refine Hash do
        def traverse
          return to_enum __method__ unless block_given?

          nodes = initialize_nodes

          until nodes.empty?
            current_node = nodes.pop
            yield current_node
            current_node.children.each &[nodes, :push]
          end
        end

        def rewrite
          hash = dup
          hash.default_proc = COMBINATOR

          nodes = initialize_nodes

          until nodes.empty?
            passed_node = nodes.pop
            returned_node = yield passed_node

            if passed_node == returned_node
              passed_node.children.each &[nodes, :push]
            else
              path = passed_node.parent.path
              cursor = if path.empty?
                         hash
                       else
                         hash.dig *path
                       end
              cursor[returned_node.key] = returned_node.value
            end
          end

          hash.default_proc = default_proc
          hash
        end

        def initialize_nodes
          nodes, root_node = Queue.new, (Node.new value: self)
          each do |key, value|
            nodes.push Node.new key: key, value: value, parent: root_node
          end
          nodes
        end
      end

      class Node
        def initialize value: nil, key: nil, parent: nil
          @value, @key, @parent = value, key, parent
        end
        attr_accessor :value, :key, :parent

        def path
          @path ||= [*parent&.path, *key]
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

        def to_a
          [key, value]
        end
      end
    end
  end
end
