function evaluations = 3humpCamel(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = 2*x(i)^2-1.05*x(i)^4+x(i)^6/6+x(i)*y(i)+y(i)^2;

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
