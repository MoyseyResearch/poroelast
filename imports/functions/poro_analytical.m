function evaluations = poro_analytical(estimates,objectives,constants)

  for i = 1:length(estimates)

    % retrieve proposed parameter values from the estimates array
    Q     = estimates{i}{1}.value;
    h     = estimates{i}{2}.value;
    mu    = estimates{i}{3}.value;
    logk  = estimates{i}{4}.value;
    gamma = estimates{i}{5}.value;
    D     = estimates{i}{6}.value;
    k = 10^logk;

    for j = 1:length(objectives)

      % retrieve independent variables if needed to run forward model
      r = objectives{j}.location.location;	% spatial
      t = objectives{j}.times.times;		% temporal

      % evaluate forward model
      rp = r.^2./(4*D.*t);
      if objectives{j}.instrument.abv=='p'
        model = Q./h./(4*pi*k./mu).*expint(rp);
      else
        model = Q./h.*gamma./(4*pi*D).*r.*( (1-exp(-rp))./rp + expint(rp) );
      end

      % compute error
      error = sum((objectives{j}.data-model).^2);

      % bundle objective, model and error into an Evaluation object
      evaluations{i}{j} = Evaluation( objectives{j}, model, error );

    end

  end
