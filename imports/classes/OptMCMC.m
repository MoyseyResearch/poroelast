classdef OptMCMC < Optimization

  properties
  end

  methods

    function obj = OptMCMC(parameters,objectives,forward,fitness,constants)
      obj = obj@Optimization(parameters,objectives,forward,fitness,constants);
    end

    function [estimates,cycles] = propose(obj)
      tic;
      [estimates,cycles] = obj.nDimensionalStep;
      if obj.constants.verbose>0
        disp(sprintf('...parameter proposal generated (t=%f)',toc));
      end
    end

    function [] = evaluate(obj,estimates,evaluations,cycles)
      tic;
      evaluateMH(obj,estimates,evaluations,cycles);
      if obj.constants.verbose>0
        disp(sprintf('...Metropolis-Hastings evaluation complete (t=%f)',toc));
      end
    end

  end
end
