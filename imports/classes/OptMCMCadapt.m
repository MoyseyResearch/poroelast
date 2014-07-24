classdef OptMCMCadapt < OptMCMC

  properties
  end

  methods

    function obj = OptMCMCadapt(parameters,objectives,forward,fitness,constants)
      tic;
      obj = obj@OptMCMC(parameters,objectives,forward,fitness,constants);
      if obj.constants.verbose>0
        disp(sprintf('...parameter proposal generated (t=%f)',toc));
      end
    end

    function population = evaluate(obj,estimates,evaluations,cycles)
      tic;
      evaluateMH(obj,estimates,evaluations,cycles);
      if obj.constants.verbose>0
        disp(sprintf('...Metropolis-Hastings evaluation complete (t=%f)',toc));
      end
      tic;
      obj.updateStepSizes;
      if obj.constants.verbose>0
        disp(sprintf('...step sizes updated (t=%f)',toc));
      end
    end

  end
end
