classdef Estimate < handle

  properties
    parameter;
    value;
  end

  methods

    function obj = Estimate(parameter,value)
      obj.parameter=parameter;
      obj.value=value;
    end

    function estimate = randomStep(obj)
      while true
        value = obj.value + randn*obj.parameter.step;
        if value>obj.parameter.constraints(1) && value<obj.parameter.constraints(2)
          estimate=Estimate(obj.parameter,value);
          break;
        end
      end
    end

  end
end
