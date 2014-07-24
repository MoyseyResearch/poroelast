function evaluations = eggholder(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = -(y(i)+47)*sin(sqrt(abs(y(i)+x(i)/2+47)))-x(i)*sin(sqrt(abs(x(i)-y(i)-47)));

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
