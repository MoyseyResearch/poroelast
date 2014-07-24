function evaluations = ackley(estimates,objectives,constants)

  for i = 1:length(estimates)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = -20*exp(-0.2*sqrt(0.5*(x(i)^2+y(i)^2)))-exp(0.5*( cos(2*pi*x(i)) + cos(2*pi*y(i)) ))+20+exp(1);

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
