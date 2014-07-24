function evaluations = poroForward(estimates,objectives,constants)

nn = constants.nn;
f1 = constants.f1;

if constants.verbose>1
  disp('...COMSOL: converting input parameters to strings');
end

E_sandStr   = '';
k_sandStr   = '';
mu_sandStr  = '';
n_sandStr   = '';
a_sandStr   = '';
E2_sandStr  = '';
k2_sandStr  = '';
mu2_sandStr = '';
n2_sandStr  = '';
a2_sandStr  = '';

for i = 1:size(estimates,2)-1
  E_sandStr   = strcat( E_sandStr,   num2str( 10^estimates{i}{1}.value ), ',' );
  k_sandStr   = strcat( k_sandStr,   num2str( 10^estimates{i}{2}.value ), ',' );
  mu_sandStr  = strcat( mu_sandStr,  num2str( estimates{i}{3}.value ),    ',' );
  n_sandStr   = strcat( n_sandStr,   num2str( estimates{i}{4}.value ),    ',' );
  a_sandStr   = strcat( a_sandStr,   num2str( estimates{i}{5}.value ),    ',' );
  E2_sandStr  = strcat( E2_sandStr,  num2str( 10^estimates{i}{6}.value ), ',' );
  k2_sandStr  = strcat( k2_sandStr,  num2str( 10^estimates{i}{7}.value ), ',' );
  mu2_sandStr = strcat( mu2_sandStr, num2str( estimates{i}{8}.value ),    ',' );
  n2_sandStr  = strcat( n2_sandStr,  num2str( estimates{i}{9}.value ),    ',' );
  a2_sandStr  = strcat( a2_sandStr,  num2str( estimates{i}{10}.value ),   ',' );
end

E_sandStr   = strcat( E_sandStr,   num2str( 10^estimates{end}{1}.value  ) );
k_sandStr   = strcat( k_sandStr,   num2str( 10^estimates{end}{2}.value  ) );
mu_sandStr  = strcat( mu_sandStr,  num2str( estimates{end}{3}.value     ) );
n_sandStr   = strcat( n_sandStr,   num2str( estimates{end}{4}.value     ) );
a_sandStr   = strcat( a_sandStr,   num2str( estimates{end}{5}.value     ) );
E2_sandStr  = strcat( E2_sandStr,  num2str( 10^estimates{end}{6}.value  ) );
k2_sandStr  = strcat( k2_sandStr,  num2str( 10^estimates{end}{7}.value  ) );
mu2_sandStr = strcat( mu2_sandStr, num2str( estimates{end}{8}.value     ) );
n2_sandStr  = strcat( n2_sandStr,  num2str( estimates{end}{9}.value     ) );
a2_sandStr  = strcat( a2_sandStr,  num2str( estimates{end}{10}.value    ) );

if constants.verbose>1
  disp('...COMSOL: connecting to comsol server');
end

addpath /software/comsol/comsol43b/mli
mphstart(2036)
import com.comsol.model.*
import com.comsol.model.util.*

if constants.verbose>1
  disp('...COMSOL: creating model object, defining parameters');
end

model = ModelUtil.create('Model');
model.modelPath('/home/achanna/mcmc/poro_numerical');
model.name('poroForward.mph');
model.comments('f1 will change the mesh density.   ');

model.param.set('Q', '0.6E-2[m^3/s]');
model.param.set('aq_thickness', '100[m]');
model.param.set('K1', '1E-6[m/s]');
model.param.set('well_radius', '0.1[m]');
model.param.set('S1', '1E-5*100');
model.param.set('f1', num2str(f1), 'adjusts mesh density');
model.param.set('param_E',   num2str(10^estimates{1}{1}.value) );
model.param.set('param_k',   num2str(10^estimates{1}{2}.value) );
model.param.set('param_mu',  num2str(estimates{1}{3}.value)    );
model.param.set('param_n',   num2str(estimates{1}{4}.value)    );
model.param.set('param_a',   num2str(estimates{1}{5}.value)    );
model.param.set('param_E2',  num2str(10^estimates{1}{6}.value) );
model.param.set('param_k2',  num2str(10^estimates{1}{7}.value) );
model.param.set('param_mu2', num2str(estimates{1}{8}.value)    );
model.param.set('param_n2',  num2str(estimates{1}{9}.value)    );
model.param.set('param_a2',  num2str(estimates{1}{10}.value)   );

model.modelNode.create('mod1');

model.func.create('step1', 'Step');
model.func('step1').model('mod1');
model.func('step1').set('funcname', 'rampup');
model.func('step1').set('location', '1');
model.func('step1').set('smooth', '2');

if constants.verbose>1
  disp('...COMSOL: defining model geometry');
end

model.geom.create('geom1', 2);
model.geom('geom1').axisymmetric(true);
model.geom('geom1').feature.create('Confining', 'Rectangle');
model.geom('geom1').feature.create('Sand', 'Rectangle');
model.geom('geom1').feature.create('basement', 'Rectangle');
model.geom('geom1').feature.create('pol1', 'Polygon');
model.geom('geom1').feature.create('pol3', 'Polygon');
model.geom('geom1').feature.create('pol4', 'Polygon');
model.geom('geom1').feature('Confining').name('confining unit');
model.geom('geom1').feature('Confining').set('pos', {'0.1' '100'});
model.geom('geom1').feature('Confining').set('size', {'30000' '1000'});
model.geom('geom1').feature('Sand').name('sand');
model.geom('geom1').feature('Sand').set('pos', {'0.1' '0'});
model.geom('geom1').feature('Sand').set('size', {'30000' '100'});
model.geom('geom1').feature('basement').name('basement');
model.geom('geom1').feature('basement').set('pos', {'0.1' '-100'});
model.geom('geom1').feature('basement').set('size', {'30000' '100'});
model.geom('geom1').feature('pol1').name('outer_mesh_control');
model.geom('geom1').feature('pol1').set('type', 'open');
model.geom('geom1').feature('pol1').set('x', '2500,2500');
model.geom('geom1').feature('pol1').set('y', '-100,1100');
model.geom('geom1').feature('pol3').name('inner_mesh_control');
model.geom('geom1').feature('pol3').set('type', 'open');
model.geom('geom1').feature('pol3').set('x', '10,10');
model.geom('geom1').feature('pol3').set('y', '-100,1100');
model.geom('geom1').feature('pol4').active(false);
model.geom('geom1').feature('pol4').name('outer_casing_wall');
model.geom('geom1').feature('pol4').set('type', 'open');
model.geom('geom1').feature('pol4').set('x', '0.108,0.108');
model.geom('geom1').feature('pol4').set('y', '-100,1100');
model.geom('geom1').feature('fin').set('repairtol', '1.0E-7');
model.geom('geom1').run;

if constants.verbose>1
  disp('...COMSOL: defining variables');
end

model.variable.create('var2');
model.variable('var2').model('mod1');
model.variable('var2').set('alpha_sandstone', 'param_a');
model.variable('var2').set('alpha_shale', 'param_a2');
model.variable('var2').set('g1', '9.81[m/s^2]');
model.variable('var2').set('pump_off_time', '1e7[s]');
model.variable('var2').set('water_bulk_modulus', '2.2E9[Pa]');
model.variable('var2').set('unjacket_bulk_modulus', '35E9[Pa]');
model.variable('var2').set('bulk_modulus_sandstone', '10E9[Pa]');
model.variable('var2').set('bulk_modulus_shale', '10E9[Pa]');
model.variable('var2').set('porosity_sandstone', 'param_n');
model.variable('var2').set('porosity_shale', 'param_n2');
model.variable('var2').set('k_shale', 'param_k2');
model.variable('var2').set('k_sandstone', 'param_k');
model.variable('var2').set('E_sandstone', 'param_E');
model.variable('var2').set('E_shale', 'param_E2');
model.variable('var2').set('poisson_sandstone', 'param_mu');
model.variable('var2').set('poisson_shale', 'param_mu2');
model.variable('var2').set('unit_weight_water', 'density_water*g1');
model.variable('var2').set('density_water', '1000[kg/m^3]');
model.variable('var2').set('p_pump', '1e6 [Pa]');
model.variable('var2').set('ppp', 'rampup(t[1/s])*p_pump');
model.variable('var2').set('compressibility_water', '1/water_bulk_modulus');
model.variable('var2').set('viscosity_water', '0.001[Pa*s]');
model.variable('var2').set('drained_density_sandstone', '2300[kg/m^3]');
model.variable('var2').set('drained_density_shale', '2700[kg/m^3]');
model.variable('var2').set('E_casing', '100E9 [Pa]');

model.variable.create('var4');
model.variable('var4').model('mod1');
model.variable('var4').set('E', 'E_shale');
model.variable('var4').set('k', 'k_shale');
model.variable('var4').set('nu', 'poisson_shale');
model.variable('var4').set('porosity', 'porosity_shale');
model.variable('var4').set('drained_density', 'drained_density_shale');
model.variable('var4').set('alpha', 'alpha_shale');
model.variable('var4').selection.geom('geom1', 2);
model.variable('var4').selection.set([1 3 4 6 7 9]);

model.variable.create('var5');
model.variable('var5').model('mod1');
model.variable('var5').set('E', 'E_sandstone');
model.variable('var5').set('k', 'k_sandstone');
model.variable('var5').set('nu', 'poisson_sandstone');
model.variable('var5').set('porosity', 'porosity_sandstone');
model.variable('var5').set('drained_density', 'drained_density_sandstone');
model.variable('var5').set('alpha', 'alpha_sandstone');
model.variable('var5').selection.geom('geom1', 2);
model.variable('var5').selection.set([2 5 8]);

model.physics.create('poro', 'Poroelasticity', 'geom1');
model.physics('poro').field('displacement').component({'ur' 'uphi' 'uz'});
model.physics('poro').feature.create('hh1', 'HydraulicHead', 1);
model.physics('poro').feature('hh1').selection.set([14 21 22 23 24]);
model.physics('poro').feature.create('roll1', 'Roller', 1);
model.physics('poro').feature('roll1').selection.set([1 2 9 16 22 23 24]);
model.physics('poro').feature.create('bndl3', 'BoundaryLoad', 1);
model.physics('poro').feature('bndl3').selection.set([3 5]);
model.physics('poro').feature.create('pr1', 'Pressure1', 1);
model.physics('poro').feature('pr1').selection.set([3]);

if constants.verbose>1
  disp('...COMSOL: defining mesh');
end

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('edg2', 'Edge');
model.mesh('mesh1').feature.create('edg3', 'Edge');
model.mesh('mesh1').feature.create('edg4', 'Edge');
model.mesh('mesh1').feature.create('edg1', 'Edge');
model.mesh('mesh1').feature.create('edg6', 'Edge');
model.mesh('mesh1').feature.create('edg5', 'Edge');
model.mesh('mesh1').feature.create('edg7', 'Edge');
model.mesh('mesh1').feature.create('map1', 'Map');
model.mesh('mesh1').feature('edg2').selection.set([1 8 15 22]);
model.mesh('mesh1').feature('edg2').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg3').selection.set([3 10 17 23]);
model.mesh('mesh1').feature('edg3').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg4').selection.set([5 12 19]);
model.mesh('mesh1').feature('edg4').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg1').selection.set([2 4 6 7]);
model.mesh('mesh1').feature('edg1').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg6').selection.set([9 11 13 14]);
model.mesh('mesh1').feature('edg6').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg5').selection.set([16 18 20 21]);
model.mesh('mesh1').feature('edg5').feature.create('dis1', 'Distribution');
model.mesh('mesh1').feature('edg7').selection.set([2 4 6 7]);
model.mesh('mesh1').feature('edg7').feature.create('dis1', 'Distribution');

model.variable('var4').name('Confining_properties');
model.variable('var5').name('reservoir_properties');

model.view('view1').set('showlabels', true);
model.view('view1').axis.set('xextra', {});
model.view('view1').axis.set('xmin', '-3731.11962890625');
model.view('view1').axis.set('ymin', '-8571.2548828125');
model.view('view1').axis.set('yextra', {});
model.view('view1').axis.set('xmax', '11558.4921875');
model.view('view1').axis.set('ymax', '11405.4482421875');

if constants.verbose>1
  disp('...COMSOL: defining poroelastic problem');
end

model.physics('poro').prop('g').set('g', 'g1');
model.physics('poro').feature('pem1').set('E_mat', 'userdef');
model.physics('poro').feature('pem1').set('E', 'E');
model.physics('poro').feature('pem1').set('nu_mat', 'userdef');
model.physics('poro').feature('pem1').set('nu', 'nu');
model.physics('poro').feature('pem1').set('rho_mat', 'userdef');
model.physics('poro').feature('pem1').set('rho', 'density_water');
model.physics('poro').feature('pem1').set('IsotropicOption', 'Enu');
model.physics('poro').feature('pem1').set('mu_mat', 'userdef');
model.physics('poro').feature('pem1').set('mu', 'viscosity_water');
model.physics('poro').feature('pem1').set('kappa_mat', 'userdef');
model.physics('poro').feature('pem1').set('kappa', {'k*viscosity_water/unit_weight_water'; '0'; '0'; '0'; 'k*viscosity_water/unit_weight_water'; '0'; '0'; '0'; 'k*viscosity_water/unit_weight_water'});
model.physics('poro').feature('pem1').set('epsilon_mat', 'userdef');
model.physics('poro').feature('pem1').set('epsilon', 'porosity');
model.physics('poro').feature('pem1').set('chif_mat', 'userdef');
model.physics('poro').feature('pem1').set('chif', 'compressibility_water');
model.physics('poro').feature('pem1').set('rhod_mat', 'userdef');
model.physics('poro').feature('pem1').set('rhod', 'drained_density');
model.physics('poro').feature('pem1').set('alphaB_mat', 'userdef');
model.physics('poro').feature('pem1').set('alphaB', 'alpha');
model.physics('poro').feature('pem1').set('minput_velocity_src', 'root.mod1.poro.uf');
model.physics('poro').feature('init1').set('H', 'h_init');
model.physics('poro').feature('bndl3').set('LoadType', 'FollowerPressure');
model.physics('poro').feature('bndl3').set('FollowerPressure', 'ppp');
model.physics('poro').feature('pr1').set('p0', 'ppp');

model.mesh('mesh1').feature('edg2').name('vert lower confining');
model.mesh('mesh1').feature('edg2').feature('dis1').set('elemratio', '10');
model.mesh('mesh1').feature('edg2').feature('dis1').set('elemcount', '18*f1');
model.mesh('mesh1').feature('edg2').feature('dis1').set('type', 'predefined');
model.mesh('mesh1').feature('edg2').feature('dis1').set('reverse', true);
model.mesh('mesh1').feature('edg3').name('vert aquifer');
model.mesh('mesh1').feature('edg3').feature('dis1').set('numelem', '25');
model.mesh('mesh1').feature('edg4').name('vert upper confining');
model.mesh('mesh1').feature('edg4').feature('dis1').set('elemratio', '12');
model.mesh('mesh1').feature('edg4').feature('dis1').set('elemcount', '100*f1');
model.mesh('mesh1').feature('edg4').feature('dis1').set('type', 'predefined');
model.mesh('mesh1').feature('edg1').name('radial inner');
model.mesh('mesh1').feature('edg1').feature('dis1').set('elemratio', '9');
model.mesh('mesh1').feature('edg1').feature('dis1').set('elemcount', '25*f1');
model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'predefined');
model.mesh('mesh1').feature('edg1').feature('dis1').set('reverse', true);
model.mesh('mesh1').feature('edg6').name('radial middle');
model.mesh('mesh1').feature('edg6').feature('dis1').set('elemratio', '8');
model.mesh('mesh1').feature('edg6').feature('dis1').set('elemcount', '80*f1');
model.mesh('mesh1').feature('edg6').feature('dis1').set('type', 'predefined');
model.mesh('mesh1').feature('edg6').feature('dis1').set('reverse', true);
model.mesh('mesh1').feature('edg5').name('radial outer');
model.mesh('mesh1').feature('edg5').feature('dis1').set('elemratio', '10');
model.mesh('mesh1').feature('edg5').feature('dis1').set('elemcount', '30*f1');
model.mesh('mesh1').feature('edg5').feature('dis1').set('type', 'predefined');
model.mesh('mesh1').feature('edg5').feature('dis1').set('reverse', true);
model.mesh('mesh1').feature('edg7').active(false);
model.mesh('mesh1').feature('edg7').name('radial casing');
model.mesh('mesh1').feature('edg7').feature('dis1').set('numelem', '2');
model.mesh('mesh1').run;

model.coordSystem('sys1').set('coord', {'t1' 'n' 'to'});

if constants.verbose>1
  disp('...COMSOL: defining study');
end
model.study.create('std6');
model.study('std6').feature.create('cluco', 'ClusterComputing');
model.study('std6').feature.create('param', 'Parametric');
model.study('std6').feature.create('time', 'Transient');
model.study('std6').name('poroelastic');
model.study('std6').feature('cluco').set('rundir', '/home/achanna/mcmc/poro_numerical');
model.study('std6').feature('cluco').set('pdistrib', true);
model.study('std6').feature('cluco').set('nn', int2str(nn));
model.study('std6').feature('cluco').set('batchdir', '/home/achanna/mcmc/poro_numerical');
model.study('std6').feature('cluco').set('batchlic', true);
model.study('std6').feature('cluco').set('batchfile', 'bench4v3_complete.mph');
model.study('std6').feature('cluco').set('mpirsh', '/usr/bin/ssh');
model.study('std6').feature('cluco').set('hostfile', '/home/achanna/mcmc/poro_numerical');
model.study('std6').feature('cluco').set('specbatchdir', 'on');
model.study('std6').feature('param').set('pname', {'param_E' 'param_k' 'param_mu' 'param_E2' 'param_k2' 'param_mu2'});
model.study('std6').feature('param').set('plistarr', {E_sandStr, k_sandStr, mu_sandStr, E2_sandStr, k2_sandStr, mu2_sandStr});
model.study('std6').feature('time').set('tlist', '10^{range(1,6/99,7)}');

if constants.verbose>1
  disp('...COMSOL: defining solution');
end

model.sol.create('sol1');
model.sol('sol1').study('std6');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std6');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature('v1').feature('mod1_u').set('scalemethod', 'manual');
model.sol('sol1').feature('v1').feature('mod1_u').set('scaleval', '1e-2*30023.990407672332');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').feature.create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', '10^{range(1,6/99,7)}');
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');
model.sol('sol1').feature('t1').set('probes', {});
model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std6');

if constants.verbose>1
  disp('...COMSOL: defining parametric sweep');
end

model.batch.create('p1', 'Parametric');
model.batch('p1').study('std6');
model.batch('p1').feature.create('so1', 'Solutionseq');
model.batch('p1').feature('so1').set('seq', 'sol1');
model.batch('p1').feature('so1').set('store', 'off');
model.batch('p1').feature('so1').set('clear', 'on');
model.batch('p1').feature('so1').set('psol', 'none');
model.batch('p1').set('pname', {'param_E' 'param_k' 'param_mu' 'param_E2' 'param_k2' 'param_mu2'});
model.batch('p1').set('plistarr', {E_sandStr, k_sandStr, mu_sandStr, E2_sandStr, k2_sandStr, mu2_sandStr});
model.batch('p1').set('sweeptype', 'sparse');
model.batch('p1').set('probesel', 'all');
model.batch('p1').set('probes', {});
model.batch('p1').set('plot', 'off');
model.batch('p1').set('err', 'on');
model.batch('p1').set('pdistrib', 'on');
model.batch('p1').attach('std6');
model.batch('p1').set('control', 'param');
model.batch.create('c1', 'Cluster');
model.batch('c1').study('std6');
model.batch('c1').set('clustertype', 'general');
model.batch('c1').set('mpd', false);
model.batch('c1').set('hostfile', '/home/achanna/mcmc/poro_numerical');
model.batch('c1').set('mpirsh', '/usr/bin/ssh');
model.batch('c1').set('nn', int2str(nn));
model.batch('c1').set('scheduler', 'localhost');
model.batch('c1').set('user', '');
model.batch('c1').attach('std6');
model.batch('b1').study('std6');
model.batch('c1').set('control', 'cluco');
model.batch('b1').feature.create('jo1', 'Jobseq');
model.batch('b1').feature('jo1').set('seq', 'p1');
model.batch('b1').set('batchfile', 'bench4v3_complete.mph');
model.batch('b1').set('batchdir', '/home/achanna/mcmc/poro_numerical');
model.batch('b1').set('specbatchdir', 'on');
model.batch('b1').set('rundir', '/home/achanna/mcmc/poro_numerical');
model.batch('b1').set('speccomsoldir', 'off');
model.batch('b1').set('comsoldir', '/opt/comsol/comsol43b');
model.batch('b1').set('synchsolutions', 'off');
model.batch('b1').attach('std6');
model.batch('b1').set('control', 'cluco');

model.sol.create('sol2');
model.sol('sol2').study('std6');
model.sol('sol2').name('Parametric 2');

model.batch('p1').feature('so1').set('psol', 'sol2');

if constants.verbose>1
  disp('...COMSOL: running simuation');
end

model.batch('c1').run;

if constants.verbose>1
  disp('...COMSOL: querying output data');
end

model.result.dataset.create('cpt1', 'CutPoint2D');
model.result.dataset('cpt1').set('data', 'dset2');
model.result.numerical.create('pev1', 'EvalPoint');
model.result.numerical('pev1').set('probetag', 'none');

model.result.table.create('tbl1', 'Table');
model.result.numerical('pev1').set('table', 'tbl1');

for j = 1:length(objectives)
  model.result.dataset('cpt1').set('pointx',  sprintf('%f',objectives{j}.location.location(1)) );
  model.result.dataset('cpt1').set('pointy',  sprintf('%f',objectives{j}.location.location(2)) );
  model.result.numerical('pev1').set('expr',  objectives{j}.instrument.abv);
  model.result.numerical('pev1').set('descr', objectives{j}.instrument.title);
  model.result.numerical('pev1').set('data', 'cpt1');
  model.result.numerical('pev1').set('unit',  objectives{j}.instrument.unit);
  model.result.numerical('pev1').setResult;
  output = model.result.table('tbl1').getReal();
  for i = 1:length(estimates)
    modelData = output((i-1)*100+1:i*100,size(output,2));
    error     = sum((objectives{j}.data-modelData).^2);
    evaluations{i}{j} = Evaluation( objectives{j}, modelData, error );
  end
end

