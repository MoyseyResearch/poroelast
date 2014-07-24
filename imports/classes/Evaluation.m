classdef Evaluation < handle

  properties
    objective;
    model;
    error;
  end

  methods

    function obj = Evaluation(objective,model,error)
      obj.objective = objective;
      obj.model     = model;
      obj.error     = error;
    end

  end

end
