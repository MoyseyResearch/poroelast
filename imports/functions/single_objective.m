function fitness = single_objective(sample)

  fitness = 1.0/sample.evaluations{1}.error;
