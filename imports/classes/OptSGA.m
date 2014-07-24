classdef OptSGA < Optimization

  properties
  end

  methods

    function obj = OptSGA(parameters,objectives,forward,fitness,constants)
      obj = obj@Optimization(parameters,objectives,forward,fitness,constants);
      obj.assignFitness;
    end

    function [estimates,cycles] = propose(obj)
      tic;
      survivors = obj.populations{end}.selection_roulette(obj.constants.survivalRate*obj.constants.nc);
      if obj.constants.verbose>0
        disp(sprintf('...selection complete (t=%f s)',toc));
      end
      tic;
      [estimates,cycles] = survivors.crossover_fitnessProportional(obj.constants.nc);
      if obj.constants.verbose>0
        disp(sprintf('...crossover complete (t=%f s)',toc));
      end
      tic;
      estimates = obj.mutate(estimates);
      if obj.constants.verbose>0
        disp(sprintf('...mutation complete (t=%f s)',toc));
      end
    end

    function [] = evaluate(obj,estimates,evaluations,cycles)
      evaluateAccept(obj,estimates,evaluations,cycles);
      tic;
      obj.assignFitness;
      if obj.constants.verbose>0
        disp(sprintf('...fitness assignments complete (t=%f s)',toc));
      end
    end

  end
end
