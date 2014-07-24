function evaluations = beale(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = (1.5-x(i)+x(i)*y(i))^2+(2.25-x(i)+x(i)*y(i)^2)^2+(2.625-x(i)+x(i)*y(i)^3)^2;

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
