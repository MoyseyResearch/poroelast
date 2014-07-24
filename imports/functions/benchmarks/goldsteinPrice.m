function evaluations = goldsteinPrice(estimates,objectives,constants)

  for i = 1:size(estimates,1)
    x(i) = estimates{i}{1}.value;
    y(i) = estimates{i}{2}.value;
  end

  for i = 1:length(estimates)

    % calculate model
    model = (1+(x(i)+y(i)+1)^2*(19-14*x(i)+3*x(i)^2-14*y(i)+6*x(i)*y(i)+3*y(i)^2))*(30+(2*x(i)-3*y(i))^2*(18-32*x(i)+12*x(i)^2+48*y(i)-36*x(i)*y(i)+27*y(i)^2));

    % compute error
    error = model;

    % bundle objective, model and error into an Evaluation object
    evaluations{i}{1} = Evaluation( objectives{1}, model, error );

  end
