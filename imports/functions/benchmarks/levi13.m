function evaluations = levi13(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = sin(3*pi*x(i))^2+(x(i)-1)^2*(1+sin(3*pi*y(i))^2)+(y(i)-1)^2*(1+sin(2*pi*y(i))^2);

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
