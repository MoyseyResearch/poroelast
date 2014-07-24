classdef (Abstract) Optimization < handle

  properties
    parameters;
    objectives;
    forward;
    fitness;
    constants;

    populations;
  end

  methods

    function obj = Optimization(parameters,objectives,forward,fitness,constants)
      if constants.verbose>0
        disp('Initializing Optimization object');
      end
      obj.parameters = parameters;
      obj.objectives = objectives;
      obj.forward    = forward;
      obj.fitness    = fitness;
      obj.constants  = constants;
      if constants.verbose>0
        disp('...Generating initial estimates from prior models');
      end
      for i = 1:obj.constants.nc
        for j = 1:length(obj.parameters)
          estimates{i}{j} = Estimate(obj.parameters{j},obj.parameters{j}.samplePrior);
        end
      end
      if constants.verbose>0
        disp('...Running forward model');
      end
      evaluations = forward(estimates,obj.objectives,obj.constants);
      for i = 1:obj.constants.nc
        samples{i} = Sample(estimates{i},evaluations{i});
        cycles{i}  = Cycle({});
        cycles{i}.accept = samples{i};
        cycles{i}.reject = {};
      end
      obj.populations{1}=Population(cycles);
    end

    function [] = iterations(varargin)
      obj = varargin{1};
      nIterations = varargin{2};
      for i = 1:nIterations
        disp(sprintf('Running iteration %i',length(obj.populations)));
        [estimates,cycles] = obj.propose;
        tic;
        evaluations        = obj.forward(estimates,obj.objectives,obj.constants);
        if obj.constants.verbose>0
          disp(sprintf('...function evaluations complete (t=%f s)',toc));
        end
        obj.evaluate(estimates,evaluations,cycles);
        if length(varargin)==3
          save(sprintf('%s_iter%05i',varargin{3},length(obj.populations)),'obj');
          save(varargin{3},'obj');
        end
      end
    end

    function [estimates,cycles] = nDimensionalStep(obj)
      for i = 1:length(obj.populations{end}.cycles)
        thisCycle{1} = obj.populations{end}.cycles{i};
        thisSample   = thisCycle{1}.accept;
        for j = 1:length(obj.parameters)
          estimates{i}{j} = thisSample.estimates{j}.randomStep;
        end
        cycles{i} = Cycle(thisCycle);
        thisCycle{1}.next{1} = cycles{i};
      end
    end

    function estimates = mutate(obj,estimates)
      for i = 1:length(estimates)
        for j = 1:length(estimates{i})
          if obj.constants.mutationRate<rand
            estimates{i}{j} = estimates{i}{j}.randomStep;
          end
        end
      end
    end

    function estimates = mutate_wMC(obj,estimates)
      for i = 1:length(estimates)
        for j = 1:length(estimates{i})
          if rand<obj.constants.mutationRate
            estimates{i}{j} = estimates{i}{j}.randomStep;
          end
          if rand<obj.constants.mcRate
            estimates{i}{j}.value = estimates{i}{j}.parameter.samplePrior;
          else
          end
        end
      end
    end

    function [] = evaluateAccept(obj,estimates,evaluations,cycles)
      for i = 1:length(cycles)
        newSample = Sample(estimates{i},evaluations{i});
        cycles{i}.accept = newSample;
        for j = 1:length(cycles{i}.last)
          cycles{i}.reject{j} = cycles{i}.last{j}.accept;
        end
      end
      obj.populations{end+1} = Population(cycles);
    end

    function [] = evaluateMH(obj,estimates,evaluations,cycles)
      for i = 1:length(cycles)
        newSample = Sample(estimates{i},evaluations{i});
        newError  = log(1.0/obj.fitness(newSample));
        for n = 1:length(cycles{i}.last)
          oldError = log(1.0/obj.fitness(cycles{i}.last{n}.accept));
          if newError<oldError || rand<log(newError-oldError)
            accept(n) = 1;
          else
            accept(n) = 0;
          end
        end
        for n = 1:length(cycles{i}.last)
          if prod(accept)
            cycles{i}.accept = newSample;
            cycles{i}.reject{length(cycles{i}.reject)+1} = cycles{i}.last{n}.accept;
            break
          else
            cycles{i}.accept = cycles{i}.last{n}.accept;
            cycles{i}.reject{length(cycles{i}.reject)+1} = newSample;
          end
        end
      end
      obj.populations{end+1} = Population(cycles);
    end

    function [estimates,cycles] = crossover_fitnessProportional(obj,survivors)
      sumFitness=0;
      for i = 1:length(survivors)
        sumFitness = sumFitness + survivors{i}.fitness;
      end
      for n = 1:length(obj.populations{end}.cycles)
        i = randi([1,length(survivors)]);
        while (survivors{i}.fitness/sumFitness)<rand
          i = randi([1,length(survivors)]);
        end
        j = randi([1,length(survivors)]);
        while i==j || (survivors{j}.fitness/sumFitness)<rand
          j = randi([1,length(survivors)]);
        end
        for k = 1:length(obj.populations{end}.cycles)
          if obj.populations{end}.cycles{k}.accept==survivors{i}
            last{1} = obj.populations{end}.cycles{k};
          elseif obj.populations{end}.cycles{k}.accept==survivors{j}
            last{2} = obj.populations{end}.cycles{k};
          end
        end
        for k = 1:length(obj.parameters)
          if rand<0.5
            estimates{n}{k}=Estimate(survivors{i}.estimates{k}.parameter,survivors{i}.estimates{k}.value);
          else
            estimates{n}{k}=Estimate(survivors{j}.estimates{k}.parameter,survivors{j}.estimates{k}.value);
          end
        end
        cycles{n}=Cycle(last);
        last{1}.next{length(last{1}.next)+1} = cycles{n};
        last{2}.next{length(last{2}.next)+1} = cycles{n};
      end
    end

    function [] = assignFitness(obj)
      for i = 1:length(obj.populations{end}.cycles)
        iCycle  = obj.populations{end}.cycles{i};
        iSample = iCycle.accept;
        iCycle.fitness = obj.fitness(iSample);
      end
    end

    function [] = assignParetoRanks(obj)
      for i = 1:length(obj.populations)
        if obj.constants.verbose>1
          disp(sprintf('Assigning pareto ranks to population %i',i));
        end
        obj.populations{i}.assignParetoRanks;
      end
    end

    function [] = updateStepSizes(obj)
      for k = 1:length(obj.parameters)
        if obj.parameters{k}.step~=0;
          for j = 1:length(obj.populations{end}.cycles)
            x(j)=obj.populations{end}.cycles{j}.accept.estimates{k}.value;
          end
          obj.parameters{k}.step = var(x)^0.5;
          clear x;
        end
      end
    end

    function [] = plotParameterEstimates(varargin)
      obj = varargin{1};
      filename = varargin{2};
      if nargin==3
        true = varargin{3};        
      end
      for k = 1:length(obj.parameters)
        if obj.parameters{k}.step>0
          disp(sprintf('Plotting parameter estimates %i',k));
          figure;
          hold on;
          for i = 1:length(obj.populations)-1
            for j = 1:length(obj.populations{i}.cycles)
              for n = 1:length(obj.populations{i}.cycles{j}.next)
                for m = 1:length(obj.populations{i}.cycles{j}.next{n}.reject)
                  this = obj.populations{i}.cycles{j}.accept.estimates{k}.value;
                  next = obj.populations{i}.cycles{j}.next{n}.reject{m}.estimates{k}.value;
                  plot( [i,i+1], [this,next], 'color', [0.6 0.6 0.6] );
                end
              end
            end
          end
          for i = 1:length(obj.populations)-1
            for j = 1:length(obj.populations{i}.cycles)
              for n = 1:length(obj.populations{i}.cycles{j}.next)
                this = obj.populations{i}.cycles{j}.accept.estimates{k}.value;
                next = obj.populations{i}.cycles{j}.next{n}.accept.estimates{k}.value;
                plot( [i,i+1], [this,next] );
              end
            end
          end
          if nargin==3
            if size(true,1)==1
              plot([1,length(obj.populations)],[true{k},true{k}],'r--','LineWidth',4);
            else
              for i = 1:size(true,1)
                plot([1,length(obj.populations)],[true{i,k},true{i,k}],'r--','LineWidth',4);
              end
            end
          end
          xlim([1 length(obj.populations)]);
          ylim(obj.parameters{k}.constraints);
          xlabel('Iterations','fontsize',40);
          ylabel(sprintf('%s [%s]',obj.parameters{k}.property.title,obj.parameters{k}.property.unit),'fontsize',40);
          set(gca,'fontsize',40);
          set(gca,'ticklength',3*get(gca,'ticklength'));
          print( '-depsc2', sprintf('%s_%02i.eps',filename,k) );
          close all;
          clear pop;
        end
      end
    end

    function [] = plotObjectiveEvaluations(varargin)
      obj = varargin{1};
      filename = varargin{2};
      if length(varargin)==3
        n = varargin{3};
      else
        n = length(obj.populations);
      end
      for k = 1:length(obj.objectives)
        disp(sprintf('Plotting objective parameter %i',k));
        figure;
        hold on;
        for i = 1:length(obj.populations{n}.cycles)
          plot(obj.objectives{k}.times.times,obj.populations{n}.cycles{i}.accept.evaluations{k}.model,'color',[0.4 0.4 0.4]);
        end
        plot(obj.objectives{k}.times.times,obj.objectives{k}.data,'b.','markersize',20);
        set(gca, 'XScale', 'log');
        xlim([obj.objectives{k}.times.times(1) obj.objectives{k}.times.times(end)]);
        ylim([ min(obj.objectives{k}.data) max(obj.objectives{k}.data)]);
        xlabel('Time [s]','fontsize',40);
        title(sprintf('%s [%s]',obj.objectives{k}.instrument.title,obj.objectives{k}.instrument.unit),'fontsize',40);
        set(gca,'XTick',logspace(obj.objectives{k}.times.times(1),obj.objectives{k}.times.times(2),3));
        set(gca,'fontsize',30);
        set(gca,'ticklength',3*get(gca,'ticklength'));
        print( '-depsc2', sprintf('%s_%02i_iter%05i.eps',filename,k,n) );
        print( '-depsc2', sprintf('%s_%02i.eps',filename,k) );
        close all;
      end
    end

    function [] = plotObjectiveFunctions(obj,filename,nx,ny,nmin,nmax,lines)
      nPar=0;
      for i = 1:length(obj.parameters)
        if obj.parameters{i}.step>0
          nPar=nPar+1;
          if nPar==1
            par1=i;
          elseif nPar==2
            par2=i;
          end
        end
      end
      if nPar~=2
        disp(sprintf('Unable to plot objective function, must be 2 dimensional'));
      else
        xmin = obj.parameters{par1}.constraints(1);
        xmax = obj.parameters{par1}.constraints(2);
        ymin = obj.parameters{par2}.constraints(1);
        ymax = obj.parameters{par2}.constraints(2);
        x = linspace(xmin,xmax,nx);
        y = linspace(ymin,ymax,ny);
        n=1;
        for i = 1:nx
        for j = 1:ny
          for k = 1:length(obj.parameters)
            if k==par1
              estimates{n}{par1} = Estimate(obj.parameters{par1},x(i));
            elseif k==par2
              estimates{n}{par2} = Estimate(obj.parameters{par2},y(j));
            else
              estimates{n}{k} = Estimate(obj.parameters{k},obj.parameters{k}.samplePrior);
            end
          end
          n=n+1;
        end
        end
        evaluations = obj.forward(estimates,obj.objectives,obj.constants);
        n=1;
        for i = 1:nx
        for j = 1:ny
          newSample = Sample(estimates{n},evaluations{n});
          z(i,j) = 1.0/obj.fitness(newSample);
          n=n+1;
        end
        end
        for n = nmin:nmax
          disp(sprintf('Plotting 2d objective function, iteration %i',n));
          figure;
          hold on;
          imagesc(x,y,z);
          colorbar;
          if lines
            for i = 1:n
              for j = 1:length(obj.populations{i}.cycles)
                for m = 1:length(obj.populations{i}.cycles{j}.next)
                  x0 = obj.populations{i}.cycles{j}.accept.estimates{par1}.value;
                  y0 = obj.populations{i}.cycles{j}.accept.estimates{par2}.value;
                  x1 = obj.populations{i}.cycles{j}.next{m}.accept.estimates{par1}.value;
                  y1 = obj.populations{i}.cycles{j}.next{m}.accept.estimates{par2}.value;
                  plot( [x0,x1], [y0,y1], 'color', [0.4 0.4 0.4] );
                end
              end
            end
          end
          for j = 1:length(obj.populations{n}.cycles)
            x1 = obj.populations{n}.cycles{j}.accept.estimates{par1}.value;
            y1 = obj.populations{n}.cycles{j}.accept.estimates{par2}.value;
            scatter(x1,y1,20,[0 0 0],'fill');
            scatter(x1,y1,15,[1 1 1],'fill');
          end
          xlim(obj.parameters{par1}.constraints);
          ylim(obj.parameters{par2}.constraints);
          xlabel(sprintf('%s [%s]',obj.parameters{par1}.property.title,obj.parameters{par1}.property.unit),'fontsize',30);
          ylabel(sprintf('%s [%s]',obj.parameters{par2}.property.title,obj.parameters{par2}.property.unit),'fontsize',30);
          set(gca,'fontsize',30);
          set(gca,'ticklength',3*get(gca,'ticklength'));
          print( '-depsc2', sprintf('%s_iter%05i.eps',filename,n) );
          print( '-depsc2', sprintf('%s.eps',filename) );
          close all;
        end
      end
    end

    function [] = plotPareto(obj,filename,par1,par2)
      disp(sprintf('Plotting pareto front along parameters %i and %i',par1,par2));
      figure;
      hold on;
      for i = 1:length(obj.populations{end}.cycles)
        x(i) = obj.populations{end}.cycles{i}.accept.evaluations{par1}.error;
        y(i) = obj.populations{end}.cycles{i}.accept.evaluations{par2}.error;
        c(i) = obj.populations{end}.cycles{i}.rank;
      end
      scatter(x,y,20,c,'fill');
      set(gca, 'XScale', 'log');
      set(gca, 'YScale', 'log');
      xlabel(sprintf('Error in %s: %s [%s]',obj.objectives{par1}.location.title,obj.objectives{par1}.instrument.title,obj.objectives{par1}.instrument.unit),'fontsize',20);
      ylabel(sprintf('Error in %s: %s [%s]',obj.objectives{par2}.location.title,obj.objectives{par2}.instrument.title,obj.objectives{par2}.instrument.unit),'fontsize',20);
      set(gca,'fontsize',30);
      set(gca,'ticklength',3*get(gca,'ticklength'));
      print( '-depsc2', sprintf('%s.eps',filename) );
      close all;
    end

    function [] = plotParetoSeries(obj,filename)
      pars=combnk(1:length(obj.objectives),2);
      for np = 1:length(pars)
        par1 = pars(np,1);
        par2 = pars(np,2);
        disp(sprintf('Plotting pareto front along parameters %i and %i',par1,par2));
        disp('...assessing xlim and ylim');
        x0=[];
        y0=[];
        for n = 1:length(obj.populations)
          for i = 1:length(obj.populations{n}.cycles)
            x0=[x0,obj.populations{n}.cycles{i}.accept.evaluations{par1}.error];
            y0=[y0,obj.populations{n}.cycles{i}.accept.evaluations{par2}.error];
          end
        end
        xmin = 10^(log10(min(x0)) - 0.1*(log10(max(x0))-log10(min(x0))));
        xmax = 10^(log10(max(x0)) + 0.1*(log10(max(x0))-log10(min(x0))));
        ymin = 10^(log10(min(y0)) - 0.1*(log10(max(y0))-log10(min(y0))));
        ymax = 10^(log10(max(y0)) + 0.1*(log10(max(y0))-log10(min(y0))));
        clear x0; clear y0;
        for n = 1:length(obj.populations)
          disp(sprintf('...plotting iteration %i',n));
          figure;
          hold on;
          for i = 1:length(obj.populations{n}.cycles)
            x(i) = obj.populations{n}.cycles{i}.accept.evaluations{par1}.error;
            y(i) = obj.populations{n}.cycles{i}.accept.evaluations{par2}.error;
            c(i) = obj.populations{n}.cycles{i}.rank;
          end
          scatter(x,y,20,c,'fill');
          clear x; clear y; clear c;
          set(gca, 'XScale', 'log');
          set(gca, 'YScale', 'log');
          xlim([ xmin,xmax ]);
          ylim([ ymin,ymax ]);
          xlabel(sprintf('Error in %s: %s [%s]',obj.objectives{par1}.location.title,obj.objectives{par1}.instrument.title,obj.objectives{par1}.instrument.unit),'fontsize',14);
          ylabel(sprintf('Error in %s: %s [%s]',obj.objectives{par2}.location.title,obj.objectives{par2}.instrument.title,obj.objectives{par2}.instrument.unit),'fontsize',14);
          set(gca,'fontsize',30);
          set(gca,'ticklength',3*get(gca,'ticklength'));
          print( '-depsc2', sprintf('%s_par%02i_par%02i_iter%05i.eps',filename,par1,par2,n) );
          close all;
        end
      end
    end

  end
end
