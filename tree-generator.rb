require 'kramdown'

module Kramdown
  module Converter
    class Tree < Base

      def initialize(root, opts)
        super
        @symbols = opts[:symbols] || :ascii
      end

      SYMBOLS = {
        :ascii => {
          :root => "o",
          :no_parent => "    ",
          :has_parent => "|   ",
          :item => "|-- ",
          :last_item => "`-- "
        },

        :utf8 => {
          :root => "•",
          :no_parent => "    ",
          :has_parent => "│   ",
          :item => "├── ",
          :last_item => "└── "
        }
      }

      def convert(el, opts = {})
        raise "Should contain a single list" if el.children[0].type != :ul || el.children.length != 1

        data = simplify(root)
        "#{SYMBOLS[@symbols][:root]}\n" + render_tree(data, @symbols)
      end

      # elements - An |Array| of hashes as generated by the |simplify| method.
      # symbols  - Symbol stating which character set from the SYMBOL table to use.
      # parents  - An |Array| of booleans. For a detailed description refer to the
      #            |indentation| method.
      #
      # Returns the rendered tree as a String
      def render_tree(elements, symbols, parents = [])
        i = 0
        x = elements.map do |li|
          last = elements.length == i+1

          current = indentation(parents, last, symbols) + li[:value]

          children = ""
          if li[:children].length > 0
            children = "\n" + render_tree(li[:children], symbols, parents + [last])
          end

          i += 1
          current + children
        end

        x.join("\n")
      end

      # Generates the indentation for a list item
      #
      # parents - An |Array| containing a boolean for each parent the list item has in the
      #           hierarchy. The value indicates whether or not the respective parent is the
      #           last element on it's hierarchy level. For example:
      #
      #             * test
      #               * foo
      #                 * more levels <-
      #               * bar
      #
      #           The highlighted element has two parents, so it's |parents| array would
      #           contain two elements. The first element would be true, since, on it's
      #           level, "test" is the last element. "foo" however is followed by "bar", and
      #           thus it's value would be false.
      #
      # last    - Boolean indicating whether this is the last element in the current hierarchy
      # symbols - Symbol stating which character set from the SYMBOL table to use.
      #
      # Returns the indentation as a String
      def indentation(parents, last, symbols)
        i = parents.map do |parent_last|
          if !parent_last
            SYMBOLS[symbols][:has_parent]
          else
            SYMBOLS[symbols][:no_parent]
          end
        end

        if last
          i.join("") + SYMBOLS[symbols][:last_item]
        else
          i.join("") + SYMBOLS[symbols][:item]
        end
      end



      # ===========================
      # Kramdown hierarchy handling
      # ===========================

      # Takes the kramdown root |Element| and strips all superfluous elements
      # which we don't need for the tree generation, leaving only list items.
      def simplify(el)
        if el.type == :p
          return text(el)
        end

        children = el.children.map { |x| simplify(x) }

        x = {
          :value => children.select { |x| x.is_a? String }.join,
          :children => children.reject { |x| x.is_a? String }.flatten
        }

        if el.type == :li
          x
        else
          x[:children]
        end
      end

      # Extract the text from a given |Element|.
      def text(el)
        return el.value if el.type == :text

        xs = el.children.map do |x|
          text(x)
        end

        xs.join(" ").gsub("\n", '')
      end

    end
  end
end
