classdef Parameter < handle

  properties
    property;
    domain;
    prior;
    constraints;
    step;
  end

  methods

    function obj = Parameter(property,domain,prior,constraints,step)
      obj.property=property;
      obj.domain=domain;
      obj.prior=prior;
      obj.constraints=constraints;
      obj.step=step;
    end

    function value = samplePrior(obj)
      while true
        value = obj.prior.random;
        if value>obj.constraints(1) && value<obj.constraints(2)
          break;
        end
      end
    end

  end
end
