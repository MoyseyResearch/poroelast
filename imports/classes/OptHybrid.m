classdef OptHybrid < Optimization

  properties
    pareto;
    elites;
  end

  methods

    function obj = OptHybrid(parameters,objectives,forward,fitness,constants)
      obj = obj@Optimization(parameters,objectives,forward,fitness,constants);
      obj.assignFitness;
      obj.pareto = Population(obj.populations{1}.cycles);
      obj.pareto = obj.pareto.identifyPareto;
      obj.elites = Population(obj.populations{1}.cycles);
      obj.elites = obj.elites.identifyElites(obj.constants.elitism);
    end

    function [estimates,cycles] = propose(obj)
      tic;
%      obj.pareto.cycles = [obj.pareto.cycles,obj.populations{end}.cycles];
      obj.pareto.cycles = [obj.populations{end}.cycles];
      obj.pareto = obj.pareto.identifyPareto;
      if obj.constants.verbose>0
        disp(sprintf('...pareto sorting complete (t=%f s, %i found)',toc,length(obj.pareto.cycles)));
      end
      obj.elites.cycles = [obj.elites.cycles,obj.populations{end}.cycles];
      obj.elites = obj.elites.identifyElites(obj.constants.elitism);
      tic;
      survivors = obj.populations{end}.selection_roulette(obj.constants.survivalRate*obj.constants.nc);
      survivors.cycles = [survivors.cycles,obj.pareto.cycles,obj.elites.cycles];
      if obj.constants.verbose>0
        disp(sprintf('...selection complete (t=%f s)',toc));
      end
      tic;
      [estimates,cycles] = survivors.crossover_fitnessProportional(obj.constants.nc);
      if obj.constants.verbose>0
        disp(sprintf('...crossover complete (t=%f s)',toc));
      end
      tic;
      estimates = obj.mutate_wMC(estimates);
      if obj.constants.verbose>0
        disp(sprintf('...mutation complete (t=%f s)',toc));
      end
    end

    function [] = evaluate(obj,estimates,evaluations,cycles)
      evaluateMH(obj,estimates,evaluations,cycles);
      tic;
      obj.assignFitness;
      if obj.constants.verbose>0
        disp(sprintf('...fitness assignments complete (t=%f s)',toc));
      end
    end

  end
end
