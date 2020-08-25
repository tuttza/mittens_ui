module MittensUi
  module Layouts
    class Stack
      class << self
        def init(window, block = Proc.new)
          stack = Gtk::Stack.new
          block.call(stack)
          window.add_child(stack)
          stack
        end

        def attach(widget, options)
          stack = options[:stack]
          if stack
            stack.add(widget)
          end
        end
      end
    end
  end
end