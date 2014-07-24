function evaluations = rosenbrock(estimates,objectives,constants)

  a = 1;
  b = 100;

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = (a-x(i))^2 + b * (y(i)-x(i)^2)^2;

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
