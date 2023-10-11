module Ha2itat::Slices
  module Blog
    module Views
      class Withoutlayout < View
        instance_eval(&Ha2itat::CD(:view))

        config.layout = "clean"
        expose :post_template
      end
    end
  end
end
