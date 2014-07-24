classdef Chromosome < handle

  properties
    parameters;
    step;
    mutation;
  end

  methods

    function obj = Chromosome(parameters)
      obj.parameters=varargin{1};
      if length(varargin)==3
        obj.step     = varargin{2};
        obj.mutation = varargin{3};
      else
        obj.step     = 1.0;
        obj.mutation = 1.0;
      end
    end

  end
end
