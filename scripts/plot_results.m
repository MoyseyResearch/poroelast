addpath ../imports/classes;
addpath ../imports/functions;

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

load('../data/poro_numerical/Hybrid/case01.mat');
obj.plotParameterEstimates('../frames/poro_numerical/Hybrid/case01/par',true);
n = length(obj.populations);
for nn = 60:n
  disp(sprintf('Plotting iteration %i of %i',nn,n));
  obj.plotObjectiveEvaluations('../frames/poro_numerical/Hybrid/case01/obj',nn);
end
