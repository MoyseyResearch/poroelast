addpath ../imports/classes;
addpath ../imports/functions;
rng('shuffle');

constants.nc           = 60;	% chains
constants.noise        = 0.10;	% noise
constants.survivalRate = 0.40;
constants.mutationRate = 0.85;
constants.mcRate       = 0.09;
constants.verbose      = 2;
constants.elitism      = 0.15;

constants.nn           = 20;	% nodes
constants.f1           = 0.2;	% resolution

forward=str2func('poro_numerical');
fitness=str2func('weighted_sums');

properties{1} = Property('Log10 Youngs Modulus','E','Pa');
properties{2} = Property('Log10 Conductivity','k','m/s');
properties{3} = Property('Poisson ratio','nu','');
properties{4} = Property('Porosity','ne','');
properties{5} = Property('Biot-Willis coefficient','a','');

domains{1} = Domain('Formation', [0 NaN]);
domains{2} = Domain('Cap Rock',  [0 NaN]);

parameters{1}  = Parameter( properties{1}, domains{1}, makedist('normal',12.8,0.2),    [7 13],      0.15 );
parameters{2}  = Parameter( properties{2}, domains{1}, makedist('normal',-8.8,0.2),    [-9 -3],     0.15 );
parameters{3}  = Parameter( properties{3}, domains{1}, makedist('normal',0.07,0.02),   [0.05 0.45], 0.03 );
parameters{4}  = Parameter( properties{4}, domains{1}, makedist('normal',0.20,0.0),    [0 1],       0 );
parameters{5}  = Parameter( properties{5}, domains{1}, makedist('normal',1.00,0.0),    [0.6 1.4],   0 );
parameters{6}  = Parameter( properties{1}, domains{2}, makedist('normal',7.2,0.2),     [7 13],      0.15 );
parameters{7}  = Parameter( properties{2}, domains{2}, makedist('normal',-9.2,0.2),    [-15 -9],    0.15 );
parameters{8}  = Parameter( properties{3}, domains{2}, makedist('normal',0.47,0.02),   [0.05 0.45], 0.03 );
parameters{9}  = Parameter( properties{4}, domains{2}, makedist('normal',0.20,0),      [0 1],       0 );
parameters{10} = Parameter( properties{5}, domains{2}, makedist('normal',1.00,0),      [0.6 1.4],   0 );

locations{1}  = Location('Injection well, Upper Formation',          [0,10]);
locations{2}  = Location('Injection well, Middle Formation',         [0,50]);
locations{3}  = Location('Injection well, Lower Formation',          [0,90]);
locations{4}  = Location('Injection well, Lower Cap rock',           [0,110]);
locations{5}  = Location('Injection well, Middle Cap rock',          [0,550]);
locations{6}  = Location('Injection well, Upper Cap rock',           [0,1050]);
locations{7}  = Location('Near observation well, Upper Formation',   [50,10]);
locations{8}  = Location('Near observation well, Middle Formation',  [50,50]);
locations{9}  = Location('Near observation well, Lower Formation',   [50,90]);
locations{10} = Location('Near observation well, Lower Cap rock',    [50,110]);
locations{11} = Location('Near observation well, Middle Cap rock',   [50,550]);
locations{12} = Location('Near observation well, Upper Cap rock',    [50,1050]);
locations{13} = Location('Far observation well, Upper Formation',    [2000,10]);
locations{14} = Location('Far observation well, Middle Formation',   [2000,50]);
locations{15} = Location('Far observation well, Lower Formation',    [2000,90]);
locations{16} = Location('Far observation well, Lower Cap rock',     [2000,110]);
locations{17} = Location('Far observation well, Middle Cap rock',    [2000,550]);
locations{18} = Location('Far observation well, Upper Cap rock',     [2000,1050]);

instruments{1} = Instrument('Pressure','pf','MPa');
instruments{2} = Instrument('Radial displacement','ur','mm');
instruments{3} = Instrument('Vertical displacement','uz','mm');
instruments{4} = Instrument('Radial Strain','poro.eZ','1');
instruments{5} = Instrument('Vertical Strain','poro.eR','1');
instruments{6} = Instrument('Circumferential Strain','poro.eRZ','1');
instruments{7} = Instrument('Tilt meter1','poro.gradUrZ','1');
instruments{8} = Instrument('Tilt meter2','poro.ePHI','1');

times{1} = Times(logspace(1,7,100),'s');

objectives{1}  = Objective( locations{8},  times{1}, instruments{1}, NaN, 1);
objectives{2}  = Objective( locations{8},  times{1}, instruments{4}, NaN, 1);
objectives{3}  = Objective( locations{8},  times{1}, instruments{5}, NaN, 1);
objectives{4}  = Objective( locations{8},  times{1}, instruments{6}, NaN, 1);
objectives{5}  = Objective( locations{8},  times{1}, instruments{7}, NaN, 1);
objectives{6}  = Objective( locations{11}, times{1}, instruments{1}, NaN, 1);
objectives{7}  = Objective( locations{11}, times{1}, instruments{4}, NaN, 1);
objectives{8}  = Objective( locations{11}, times{1}, instruments{5}, NaN, 1);
objectives{9}  = Objective( locations{11}, times{1}, instruments{6}, NaN, 1);
objectives{10} = Objective( locations{11}, times{1}, instruments{7}, NaN, 1);
%objectives{11} = Objective( locations{14}, times{1}, instruments{1}, NaN, 1);
%objectives{12} = Objective( locations{14}, times{1}, instruments{4}, NaN, 1);
%objectives{13} = Objective( locations{14}, times{1}, instruments{5}, NaN, 1);
%objectives{14} = Objective( locations{14}, times{1}, instruments{6}, NaN, 1);
%objectives{15} = Objective( locations{14}, times{1}, instruments{7}, NaN, 1);
%objectives{16} = Objective( locations{17}, times{1}, instruments{1}, NaN, 1);
%objectives{17} = Objective( locations{17}, times{1}, instruments{4}, NaN, 1);
%objectives{18} = Objective( locations{17}, times{1}, instruments{5}, NaN, 1);
%objectives{19} = Objective( locations{17}, times{1}, instruments{6}, NaN, 1);
%objectives{10} = Objective( locations{17}, times{1}, instruments{7}, NaN, 1);

true{1}  = log10(15e9);
true{2}  = -6;
true{3}  = 0.25;
true{4}  = 0.20;
true{5}  = 1;
true{6}  = log10(20e9);
true{7}  = -12;
true{8}  = 0.15;
true{9}  = 0.20;
true{10} = 1;

generate_synthetic(parameters,objectives,forward,true,constants);
opt = OptHybrid(parameters,objectives,forward,fitness,constants);
opt.iterations(50,'../data/poro_numerical/Hybrid/case01.mat');
