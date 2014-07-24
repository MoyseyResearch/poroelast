function fitness = weighted_sums(sample)

  error=0;
  for i = 1:length(sample.evaluations)
    error = error + log10(sample.evaluations{i}.error / var(sample.evaluations{i}.objective.data));
  end

  fitness = 1.0/error;
