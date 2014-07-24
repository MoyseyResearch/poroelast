addpath ../imports/classes;
addpath ../imports/functions;
rng('shuffle');

constants.nc           = 300;	% chains
constants.noise        = 0.01;	% noise
constants.survivalRate = 0.40;
constants.mutationRate = 0.80;
constants.mcRate       = 0.05;
constants.verbose      = 1;
constants.elitism      = 0.10;

forward=str2func('poro_analytical');
fitness=str2func('weighted_sums');

properties{1} = Property('Pumping rate','Q','m^3/s');
properties{2} = Property('Screened interval','h','m');
properties{3} = Property('Poisson ratio','nu','');
properties{4} = Property('log10 Permeability','logk','m^2');
properties{5} = Property('Loading efficiency','gamma','');
properties{6} = Property('Diffusion coeffecient','D','m^2/s');

domains{1} = Domain('1d',[0 NaN]);

parameters{1}  = Parameter( properties{1}, domains{1}, makedist('normal',1e-3,0.5e-3),            [0.5e-3 1.5e-3], 0.05e-3    );
parameters{2}  = Parameter( properties{2}, domains{1}, makedist('normal',100,100),             [20 180],        0.5    );
parameters{3}  = Parameter( properties{3}, domains{1}, makedist('normal',1e-3,0.5e-3),            [0.5e-3 1.5e-3], 0.05e-3    );
parameters{4}  = Parameter( properties{4}, domains{1}, makedist('normal',log10(1.02e-13),2), [-15 -11],       0.05 );
parameters{5}  = Parameter( properties{5}, domains{1}, makedist('normal',0.379,0.5),         [0 1],           0.02 );
parameters{6}  = Parameter( properties{6}, domains{1}, makedist('normal',0.814,4),           [0 5],           0.05 );

locations{1} = Location('Injection well, r=0.2m',[0.2]);
locations{2} = Location('Observation well 1, r=20m',[20]);
locations{3} = Location('Observation well 2, r=200m',[20]);

instruments{1} = Instrument('Pressure','p','Pa');
instruments{2} = Instrument('Displacement','d','mm');

times{1} = Times(logspace(-2,log10(3600*6),100),'s');

objectives{1}  = Objective( locations{1}, times{1}, instruments{1}, NaN, 1);
objectives{2}  = Objective( locations{1}, times{1}, instruments{2}, NaN, 1);
objectives{3}  = Objective( locations{2}, times{1}, instruments{1}, NaN, 1);
objectives{4}  = Objective( locations{2}, times{1}, instruments{2}, NaN, 1);
objectives{5}  = Objective( locations{3}, times{1}, instruments{1}, NaN, 1);
objectives{6}  = Objective( locations{3}, times{1}, instruments{2}, NaN, 1);

true{1} = 1e-3;
true{2} = 100;
true{3} = 0.001;
true{4} = log10(1.02e-13);
true{5} = 0.379;
true{6} = 0.814;

generate_synthetic(parameters,objectives,forward,true,constants);


for i = 10:300
  constants.nc = i;
  constants.verbose = 0;
  opt4 = OptHybrid(parameters,objectives,forward,fitness,constants);
  opt4.iterations(1);
  t(i,1) = i;
  tic;
  opt4.populations{end}.identifyPareto;
  t(i,2) = toc;
  tic;
  opt4.populations{end}.sortByFitness;
  t(i,3) = toc;
  tic;
  opt4.populations{end}.assignParetoRanks;
  t(i,4) = toc;
  tic;
  opt4.populations{end}.identifyDominated;
  t(i,5) = toc;
  disp(sprintf('n=%i, rank1=%f s, sort=%f s, assign ranks=%f s, dominated=%f s',t(i,:)));
end
