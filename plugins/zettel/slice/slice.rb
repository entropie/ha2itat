module Ha2itat::Slices::Zettel
  class Slice < Ha2itat::Slices::BackendSlice
    config.root = __dir__

    instance_eval(&Ha2itat::CD(:slice))
  end
end
