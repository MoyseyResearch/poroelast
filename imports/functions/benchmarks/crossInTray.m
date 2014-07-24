function evaluations = crossInTray(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = -0.0001*(abs(sin(x(i))*sin(y(i))*exp(abs(100-sqrt(x(i)^2+y(i)^2)/pi)))+1)^0.1;

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
