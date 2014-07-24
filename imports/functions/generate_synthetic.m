function [] = generate_synthetic(parameters,objectives,forward,true,constants)

  if constants.verbose>0
    disp('Running forward model to generate synthetic data');
  end

  if size(true,1)==1
    for j = 1:size(true,2)
      estimates{1}{j} = Estimate(parameters{j},true{j});
    end
  else
    for j = 1:size(true,2)
      estimates{1}{j} = Estimate(parameters{j},true{1,j});
    end
  end

  evaluations=forward(estimates,objectives,constants);
  for j = 1:length(objectives)
    data  = evaluations{1}{j}.model;
    noise = 1+constants.noise*randn(size(data));
    objectives{j}.data = data .* noise;
  end

  end
