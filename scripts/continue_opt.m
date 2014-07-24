addpath ../imports/classes;
addpath ../imports/functions;

fname = '../data/poro_numerical/Hybrid/case01.mat';
load(fname);
%obj.updateStepSizes;
%obj.constants.mcRate = 0.01;
obj.iterations(500-length(obj.populations),fname);
