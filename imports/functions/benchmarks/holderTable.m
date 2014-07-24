function evaluations = holderTable(estimates,objectives,constants)

  for i = 1:length(estimates)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = -abs(sin(x(i))*cos(y(i))*exp(abs(1-sqrt(x(i)^2+y(i)^2)/pi)));

    % compute error
    error = model-objectives{1}.data;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
