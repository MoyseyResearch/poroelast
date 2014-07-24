addpath ../imports/classes;
addpath ../imports/functions;
addpath ../imports/functions/benchmarks;
rng('shuffle');

constants.nc           = 60;	% chains
constants.noise        = 0.00;	% noise
constants.survivalRate = 0.40;
constants.mutationRate = 0.80;
constants.mcRate       = 0.05;
constants.verbose      = 1;
constants.elitism      = 0.10;

forward=str2func('ackley');
fitness=str2func('single_objective');

properties{1} = Property('x','x','-');
properties{2} = Property('y','y','-');

domains{1} = Domain('1d',[0 NaN]);

parameters{1}  = Parameter( properties{1}, domains{1}, makedist('normal',0,4), [-5 +5], 0.20 );
parameters{2}  = Parameter( properties{2}, domains{1}, makedist('normal',0,4), [-5 +5], 0.20 );

locations{1} = Location('Ackley',[NaN]);
instruments{1} = Instrument('Single','','-');

times{1} = Times([NaN],'-');

objectives{1}  = Objective( locations{1}, times{1}, instruments{1}, NaN, 1);

true{1} = 0;
true{2} = 0;

generate_synthetic(parameters,objectives,forward,true,constants);

name = 'ackley';

opt1 = OptMCMC(parameters,objectives,forward,fitness,constants);
opt1.iterations(200);
opt1.plotParameterEstimates(sprintf('../frames/benchmarks/%s/MCMC/par',name),true);
%opt1.plotObjectiveFunctions(sprintf('../frames/benchmarks/%s/MCMC/objFn',name),100,100,201,201,1);
save(sprintf('../data/benchmarks/%s/MCMC.mat',name),'true','opt1');

opt2 = OptMCMCadapt(parameters,objectives,forward,fitness,constants);
opt2.iterations(200);
opt2.plotParameterEstimates(sprintf('../frames/benchmarks/%s/MCMCadapt/par',name),true);
%opt2.plotObjectiveFunctions(sprintf('../frames/benchmarks/%s/MCMCadapt/objFn',name),100,100,201,201,1);
save(sprintf('../data/benchmarks/%s/MCMCadapt.mat',name),'true','opt2');

opt3 = OptSGA(parameters,objectives,forward,fitness,constants);
opt3.iterations(200);
opt3.plotParameterEstimates(sprintf('../frames/benchmarks/%s/SGA/par',name),true);
%opt3.plotObjectiveFunctions(sprintf('../frames/benchmarks/%s/SGA/objFn',name),100,100,201,201,1);
save(sprintf('../data/benchmarks/%s/SGA.mat',name),'true','opt3');

opt4 = OptHybrid(parameters,objectives,forward,fitness,constants);
opt4.iterations(200);
opt4.plotParameterEstimates(sprintf('../frames/benchmarks/%s/Hybrid/par',name),true);
%opt4.plotObjectiveFunctions(sprintf('../frames/benchmarks/%s/Hybrid/objFn',name),100,100,201,201,1);
save(sprintf('../data/benchmarks/%s/Hybrid.mat',name),'true','opt4');
