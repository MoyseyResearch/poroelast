classdef Population < handle

  properties
    cycles;
  end

  methods

    function obj = Population(cycles)
      obj.cycles=cycles;
    end

    function selected = selection_roulette(obj,n)
      for i = 1:length(obj.cycles)
        cycles{i} = obj.cycles{i};
      end
      selected={};
      while length(selected)<n
        sumFitness=0;
        for i = 1:length(cycles)
          sumFitness = sumFitness + cycles{i}.fitness;
        end
        spin = sumFitness*rand;
        sum = 0;
        for i = 1:length(cycles)
          sum = sum + cycles{i}.fitness;
          if sum>spin
            selected{length(selected)+1} = cycles{i};
            cycles(i)=[];
            break;
          end
        end
      end
      selected = Population(selected);
    end

%    function selected = selection_tournament(obj,n)
%      % not yet implemented
%    end

    function [estimates,cycles] = crossover_fitnessProportional(obj,nPop)
      for n = 1:nPop
        parents=obj.selection_roulette(2);
        for k = 1:length(parents.cycles{1}.accept.estimates)
          if rand<0.5
            estimates{n}{k}=Estimate(parents.cycles{1}.accept.estimates{k}.parameter,parents.cycles{1}.accept.estimates{k}.value);
          else
            estimates{n}{k}=Estimate(parents.cycles{2}.accept.estimates{k}.parameter,parents.cycles{2}.accept.estimates{k}.value);
          end
        end
        cycles{n}=Cycle(parents.cycles);
        parents.cycles{1}.next{length(parents.cycles{1}.next)+1} = cycles{n};
        parents.cycles{2}.next{length(parents.cycles{2}.next)+1} = cycles{n};
      end
    end

    function [] = sortByFitness(obj)
      for i = 1:length(obj.cycles)
        x(i) = obj.cycles{i}.fitness;
      end
      [x,I] = sort(x,'descend');
      for i = 1:length(obj.cycles)
        sorted{i} = obj.cycles{I(i)};
      end
      obj.cycles = sorted;
    end

    function [] = identifyDominated(obj)
      for i = 1:length(obj.cycles)
        obj.cycles{i}.dominating  = {};
        obj.cycles{i}.dominatedBy = {};
      end
      for i = 1:length(obj.cycles)
        for j = 1:length(obj.cycles)
          for k = 1:length(obj.cycles{j}.accept.evaluations)
            par(k) = obj.cycles{j}.accept.evaluations{k}.error<obj.cycles{i}.accept.evaluations{k}.error;
          end
          if prod(par)==1
            obj.cycles{j}.dominating  = [obj.cycles{i}.dominating  obj.cycles{i}];
            obj.cycles{i}.dominatedBy = [obj.cycles{i}.dominatedBy obj.cycles{j}];
          end
        end
      end
      for i = 1:length(obj.cycles)
        obj.cycles{i}.dominating = Population(obj.cycles{i}.dominating);
        obj.cycles{i}.dominatedBy = Population(obj.cycles{i}.dominatedBy);
      end
    end

    function [] = assignParetoRanks(varargin)
      obj = varargin{1};
      if length(varargin)==2
        rank = varargin{2};
      else
        rank = 1;
      end
      for i = 1:length(obj.cycles)
        cycles{i} = obj.cycles{i};
        cycles{i}.rank=rank;
      end
      found=0;
      for i = 1:length(cycles)
        for j = 1:length(cycles)
          for k = 1:length(cycles{j}.accept.evaluations)
            par(k) = cycles{j}.accept.evaluations{k}.error<cycles{i}.accept.evaluations{k}.error;
          end
          if prod(par)==1
            cycles{i}.rank=cycles{i}.rank+1;
            found=found+1;
            break;
          end
        end
      end
      while true
        for i = 1:length(cycles)
          if cycles{i}.rank==rank
            cycles(i)=[];
            break;
          end
        end
        if i==length(cycles) || length(cycles)==0; break; end
      end
      if found>0
        newPop=Population(cycles);
        newPop.assignParetoRanks(rank+1);
      end
    end

    function pareto = identifyPareto(obj)
      for i = 1:length(obj.cycles)
        cycles{i} = obj.cycles{i};
      end
      pareto={};
      for i = 1:length(cycles)
        found=0;
        for j = 1:length(cycles)
          for k = 1:length(cycles{j}.accept.evaluations)
            par(k) = cycles{j}.accept.evaluations{k}.error<cycles{i}.accept.evaluations{k}.error;
          end
          if prod(par)==1
            found=1;
            break;
          end
        end
        if found==0
          pareto{length(pareto)+1} = cycles{i};
        end
      end
      pareto=Population(pareto);
    end

    function elites = identifyElites(obj,elitism)
      obj.sortByFitness;
      for i = 1:elitism*length(obj.cycles)
        selected{i} = obj.cycles{i};
      end
      elites = Population(selected);
    end

  end
end
