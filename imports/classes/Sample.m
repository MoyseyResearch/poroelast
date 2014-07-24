classdef Sample < handle

  properties
    estimates;
    evaluations;
  end

  methods

    function obj = Sample(estimates,evaluations)
      obj.estimates = estimates;
      obj.evaluations = evaluations;
    end

  end

end
