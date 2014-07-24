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

forward=str2func('holderTable');
fitness=str2func('single_objective');

properties{1} = Property('x','x','-');
properties{2} = Property('y','y','-');

domains{1} = Domain('1d',[0 NaN]);

parameters{1}  = Parameter( properties{1}, domains{1}, makedist('normal',0,8), [-10 +10], 0.20 );
parameters{2}  = Parameter( properties{2}, domains{1}, makedist('normal',0,8), [-10 +10], 0.20 );

locations{1} = Location('Holder Table',[NaN]);
instruments{1} = Instrument('Single','','-');

times{1} = Times([NaN],'-');

objectives{1}  = Objective( locations{1}, times{1}, instruments{1}, NaN, 1);

true{1,1} = 8.05502;
true{1,2} = 9.66459;
true{2,1} = -8.05502;
true{2,2} = 9.66459;
true{3,1} = 8.05502;
true{3,2} = -9.66459;
true{4,1} = -8.05502;
true{4,2} = -9.66459;

generate_synthetic(parameters,objectives,forward,true,constants);

opt1 = OptMCMC(parameters,objectives,forward,fitness,constants);
opt1.iterations(200);
opt1.plotParameterEstimates('../frames/benchmarks/holderTable/MCMC/par',true);
%opt1.plotObjectiveFunctions('../frames/benchmarks/holderTable/MCMC/objFn',100,100,201,201,1);
save('../data/benchmarks/holderTable/MCMC.mat','true','opt1');

opt2 = OptMCMCadapt(parameters,objectives,forward,fitness,constants);
opt2.iterations(200);
opt2.plotParameterEstimates('../frames/benchmarks/holderTable/MCMCadapt/par',true);
%opt2.plotObjectiveFunctions('../frames/benchmarks/holderTable/MCMCadapt/objFn',100,100,201,201,1);
save('../data/benchmarks/holderTable/MCMCadapt.mat','true','opt2');

opt3 = OptSGA(parameters,objectives,forward,fitness,constants);
opt3.iterations(200);
opt3.plotParameterEstimates('../frames/benchmarks/holderTable/SGA/par',true);
%opt3.plotObjectiveFunctions('../frames/benchmarks/holderTable/SGA/objFn',100,100,201,201,1);
save('../data/benchmarks/holderTable/SGA.mat','true','opt3');

opt4 = OptHybrid(parameters,objectives,forward,fitness,constants);
opt4.iterations(200);
opt4.plotParameterEstimates('../frames/benchmarks/holderTable/Hybrid/par',true);
%opt4.plotObjectiveFunctions('../frames/benchmarks/holderTable/Hybrid/objFn',100,100,201,201,1);
save('../data/benchmarks/holderTable/Hybrid.mat','true','opt4');
