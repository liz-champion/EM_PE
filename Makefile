directories:
	mkdir -p pe_runs/

TMIN = 0.5
TMAX = 20.0
MEJ = 0.03
VEJ = 0.2
MEJ_BLUE = 0.020
MEJ_PURPLE = 0.050
MEJ_RED = 0.010
MEJ_DYN=0.02
MEJ_WIND=0.025
VEJ_BLUE = 0.25
VEJ_PURPLE = 0.15
VEJ_RED = 0.15
VEJ_DYN=0.15
VEJ_WIND=0.2
TC_BLUE = 700.0
TC_PURPLE = 1300.0
TC_RED = 3700.0
SIGMA = 0.1
DIST = 40.0
M1 = 1.4
M2 = 1.35

### general injection parameters
INJECTION_PARAMS = --n 15 --err 0.25 --sigma ${SIGMA} --time-format mjd --tmin ${TMIN} --tmax ${TMAX} --p dist ${DIST}
EJECTA_PARAMS = --p mej ${MEJ} --p vej ${VEJ} --p kappa 1.0 --p sigma ${SIGMA}
EJECTA_PARAMS_3C = --p mej_red ${MEJ_RED} --p mej_purple ${MEJ_PURPLE} --p mej_blue ${MEJ_BLUE} --p vej_red ${VEJ_RED} --p vej_purple ${VEJ_PURPLE} --p vej_blue ${VEJ_BLUE} --p Tc_red ${TC_RED} --p Tc_purple ${TC_PURPLE} --p Tc_blue ${TC_BLUE} --p sigma ${SIGMA}
EJECTA_PARAMS_INTERP = --p mej_dyn ${MEJ_DYN} --p vej_dyn ${VEJ_DYN} --p mej_wind ${MEJ_WIND} --p vej_wind ${VEJ_WIND}
INJECTION_PARAMS_INTERP = --n 25 --err 0.2 --time-format mjd --tmin ${TMIN} --tmax 20.0 --p dist ${DIST}
BNS_PARAMS = --p m1 ${M1} --p m2 ${M2}

test_kilonova: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/generate_data.py --m kilonova --out pe_runs/$@_$(shell date +%Y%m%d)/ ${INJECTION_PARAMS} ${EJECTA_PARAMS}
	echo "time python3 ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kilonova -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 20 --max 20 --out samples.txt --fixed-param dist 40.0 --fixed-param kappa 1.0 --correlate-dims mej vej --burn-in 10 --beta-start 0.001 --beta-end 0.1 --keep-npts 2000000 --nprocs 8" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --truth-file test_truths.txt --out corner.png --p mej --p vej --p sigma" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kilonova --tmin ${TMIN} --tmax ${TMAX} --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0 --fixed-param kappa 1.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

test_kilonova_3c: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/generate_data.py --m kilonova_3c --out pe_runs/$@_$(shell date +%Y%m%d)/ ${INJECTION_PARAMS} ${EJECTA_PARAMS_3C}
	echo "time python3 ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kilonova_3c -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 20 --max 20 --out samples.txt --fixed-param dist 40.0 --burn-in 10 --beta-start 0.001 --keep-npts 2000000 --nprocs 8 --fixed-param Tc_red ${TC_RED} --fixed-param Tc_purple ${TC_PURPLE} --fixed-param Tc_blue ${TC_BLUE}" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --truth-file test_truths.txt --out corner.png --p mej_red --p mej_purple --p mej_blue --p vej_red --p vej_purple --p vej_blue --p sigma" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kilonova_3c --tmin ${TMIN} --tmax ${TMAX} --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0 --fixed-param Tc_red ${TC_RED} --fixed-param Tc_purple ${TC_PURPLE} --fixed-param Tc_blue ${TC_BLUE}" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

test_kn_interp: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/generate_data.py --m kn_interp --out pe_runs/$@_$(shell date +%Y%m%d)/ ${INJECTION_PARAMS_INTERP} ${EJECTA_PARAMS_INTERP}
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 40 --max 40 --out samples.txt --fixed-param dist 40.0 --burn-in 10 --beta-start 0.005 --keep-npts 1000000 --set-limit mej_dyn 0.01 0.03 --set-limit mej_wind 0.015 0.035 --correlate-dims mej_dyn vej_dyn --correlate-dims mej_wind vej_wind" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --truth-file test_truths.txt --out corner.png --p mej_dyn --p vej_dyn --p mej_wind --p vej_wind" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kn_interp --tmin ${TMIN} --tmax 6.7 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

test_kn_interp_angle: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/generate_data.py --m kn_interp_angle --out pe_runs/$@_$(shell date +%Y%m%d)/ ${INJECTION_PARAMS_INTERP} ${EJECTA_PARAMS_INTERP} --p theta 20.0
	echo "#!/bin/sh" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp_angle -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 15 --max 15 --out samples.txt --fixed-param dist 40.0 --burn-in 5 --beta-start 0.005 --beta-end 0.1 --keep-npts 1000000" >> pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples-combined.txt --out corner.png --p mej_dyn --p mej_wind --p vej_dyn --p vej_wind --p theta" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples-combined.txt --out lc.png --m kn_interp_angle --tmin ${TMIN} --tmax 20 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/scripts/combine_posterior_samples.py --input-file samples-1.txt samples-2.txt samples-3.txt samples-4.txt samples-5.txt samples-6.txt --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/combine.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/combine.sh
	cp ~/template.sub pe_runs/$@_$(shell date +%Y%m%d)/run.sub
	sed -i 's/samples.txt/samples-\$$1.txt/' pe_runs/$@_$(shell date +%Y%m%d)/sample.sh

### GW170817

GW170817_START = 1187008882.43
TMAX = 30.0

GW170817_kilonova_3c: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/em_pe/parser/parse_json.py --t0 ${GW170817_START} --f ${EM_PE_INSTALL_DIR}/Data/GW170817.json --b g --b r --b i --b z --b y --b J --b H --b K --out pe_runs/$@_$(shell date +%Y%m%d)/
	echo "time python3 ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kilonova_3c -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 40 --max 40 --out samples.txt --fixed-param dist 40.0 --correlate-dims mej_red vej_red --correlate-dims mej_purple vej_purple --correlate-dims mej_blue vej_blue --burn-in 20 --beta-start 0.005 --beta-end 0.1 --nprocs 8 --keep-npts 1000000 --set-limit mej_blue 0.01 0.02 --set-limit mej_purple 0.037 0.043 --set-limit mej_red 0.009 0.015 --set-limit vej_red 0.1 0.18 --set-limit vej_purple 0.122 0.138 --set-limit vej_blue 0.25 0.28 --set-limit Tc_red 2500.0 3700.0 --set-limit Tc_purple 1000.0 1250.0 --set-limit Tc_blue 400.0 1200.0 --ncomp Tc_blue 2 " > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej_red --p mej_purple --p mej_blue --p vej_red --p vej_purple --p vej_blue --p sigma --p Tc_red --p Tc_purple --p Tc_blue" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kilonova_3c --tmin ${TMIN} --tmax ${TMAX} --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

GW170817_kn_interp: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/em_pe/parser/parse_json.py --t0 ${GW170817_START} --tmax 6.7 --f ${EM_PE_INSTALL_DIR}/Data/GW170817.json --b g --b r --b i --b z --b y --b J --b H --b K --out pe_runs/$@_$(shell date +%Y%m%d)/
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 45 --max 45 --out samples.txt --fixed-param dist 40.0 --burn-in 15 --beta-start 0.005 --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej_dyn --p mej_wind --p vej_dyn --p vej_wind" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kn_interp --tmin ${TMIN} --tmax 6.7 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

GW170817_kn_interp_angle: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/em_pe/parser/parse_json.py --t0 ${GW170817_START} --tmax 37 --f ${EM_PE_INSTALL_DIR}/Data/GW170817.json --b g --b r --b i --b z --b y --b J --b H --b K --out pe_runs/$@_$(shell date +%Y%m%d)/
	echo "#!/bin/sh" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp_angle -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 15 --max 15 --out samples.txt --fixed-param dist 40.0 --burn-in 5 --beta-start 0.005 --beta-end 0.1 --keep-npts 1000000 --gaussian-prior-theta 20.0 5.0" >> pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples-combined.txt --out corner.png --p mej_dyn --p mej_wind --p vej_dyn --p vej_wind --p theta" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples-combined.txt --out lc.png --m kn_interp_angle --tmin ${TMIN} --tmax 20 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/scripts/combine_posterior_samples.py --input-file samples-1.txt samples-2.txt samples-3.txt samples-4.txt samples-5.txt samples-6.txt --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/combine.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/combine.sh
	cp ~/template.sub pe_runs/$@_$(shell date +%Y%m%d)/run.sub
	sed -i 's/samples.txt/samples-\$$1.txt/' pe_runs/$@_$(shell date +%Y%m%d)/sample.sh

kilonova_pp_plot: directories
	python3 ${EM_PE_INSTALL_DIR}/scripts/pp_plot_helper_condor.py --m kilonova --directory pe_runs/ --name pp_plot_$(shell date +%Y%m%d) --npts 50 --fixed-param dist ${DIST} --fixed-param kappa 5.0 --fixed-param sigma 0.0
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/pp_plot.py --m kilonova --name \"\" --directory ./" > pe_runs/pp_plot_$(shell date +%Y%m%d)/plot.sh
	chmod u+x pe_runs/pp_plot_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/pp_plot_$(shell date +%Y%m%d)/*/generate_data.sh
	chmod u+x pe_runs/pp_plot_$(shell date +%Y%m%d)/plot.sh

kilonova_3c_pp_plot: directories
	chmod u+x pe_runs/pp_plot/run.sh
	python3 ${EM_PE_INSTALL_DIR}/scripts/pp_plot_helper.py --m kilonova_3c --directory pe_runs/ --name pp_plot_$(shell date +%Y%m%d) --npts 100 --sigma 0.1 --sampler-args "--correlate-dims mej_red vej_red --correlate-dims mej_purple vej_purple --correlate-dims mej_blue vej_blue" --fixed-param dist ${DIST} --fixed-param Tc_red ${TC_RED} --fixed-param Tc_purple ${TC_PURPLE} --fixed-param Tc_blue ${TC_BLUE}
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/pp_plot.py --m kilonova_3c --name \"\" --directory ./" > pe_runs/pp_plot_$(shell date +%Y%m%d)/plot.sh
	chmod u+x pe_runs/pp_plot_$(shell date +%Y%m%d)/run.sh
	chmod u+x pe_runs/pp_plot_$(shell date +%Y%m%d)/plot.sh

simulation_injection_kn_interp: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/setup_simulation_injection.py --input-sim ${KN_SIM_DIR}/Run_TP_dyn_all_lanth_wind2_all_md0.01_vd0.3_mw0.01_vw0.3_mags_2019-12-26.dat --tmin 0.1 --tmax 6.7 --n 30 --err 0.15 --out pe_runs/$@_$(shell date +%Y%m%d)/ --angular-bin 5 --dist 40.0
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 40 --max 40 --out samples.txt --fixed-param dist 40.0 --burn-in 10 --beta-start 0.005 --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej_dyn --p mej_wind --p vej_dyn --p vej_wind" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kn_interp --tmin ${TMIN} --tmax 6.7 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

simulation_injection_kilonova: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/setup_simulation_injection.py --input-sim ${KN_SIM_DIR}/Run_TP_dyn_all_lanth_wind2_all_md0.01_vd0.3_mw0.01_vw0.3_mags_2019-12-26.dat --tmin 0.1 --tmax 6.7 --n 30 --err 0.15 --out pe_runs/$@_$(shell date +%Y%m%d)/ --angular-bin 5 --dist 40.0
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kilonova -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 20 --max 20 --out samples.txt --fixed-param dist 40.0 --burn-in 10 --beta-start 0.005 --beta-end 0.1 --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej --p vej --p kappa --p sigma" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kilonova --tmin ${TMIN} --tmax 6.7 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

simulation_injection_kilonova_3c: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	python3 ${EM_PE_INSTALL_DIR}/scripts/setup_simulation_injection.py --input-sim ${KN_SIM_DIR}/Run_TP_dyn_all_lanth_wind2_all_md0.01_vd0.3_mw0.01_vw0.3_mags_2019-12-26.dat --tmin 0.1 --tmax 6.7 --n 30 --err 0.15 --out pe_runs/$@_$(shell date +%Y%m%d)/ --angular-bin 5 --dist 40.0
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kilonova_3c -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 20 --max 20 --out samples.txt --fixed-param dist 40.0 --fixed-param Tc_red 4000.0 --fixed-param Tc_purple 4000.0 --fixed-param Tc_blue 4000.0 --burn-in 10 --beta-start 0.005 --beta-end 0.1 --keep-npts 1000000" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej_red --p vej_red --p mej_purple --p vej_purple --p mej_blue --p vej_blue --p sigma" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kilonova_3c --tmin ${TMIN} --tmax 6.7 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh

simulation_injection_kn_interp_angle: directories
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/
	mkdir -p pe_runs/$@_$(shell date +%Y%m%d)/temp/
	#python3 ${EM_PE_INSTALL_DIR}/em_pe/parser/parse_json.py --t0 ${GW170817_START} --tmax 6.7 --f ${EM_PE_INSTALL_DIR}/Data/GW170817.json --b g --b r --b i --b z --b y --b J --b H --b K --out pe_runs/$@_$(shell date +%Y%m%d)/temp/
	python3 ${EM_PE_INSTALL_DIR}/scripts/setup_simulation_injection.py --input-sim ${HOME}/Run_TP_dyn_all_lanth_wind2_all_md0.097050_vd0.197642_mw0.083748_vw0.297978_mags_2020-11-03.dat --tmin 0.1 --tmax 20.0 --n 30 --err 0.25 --out pe_runs/$@_$(shell date +%Y%m%d)/ --angular-bin 2 --dist 40.0 # --GW170817-times --GW170817-loc pe_runs/$@_$(shell date +%Y%m%d)/temp/
	#python3 ${EM_PE_INSTALL_DIR}/scripts/setup_simulation_injection.py --input-sim ${KN_SIM_DIR_AL}/Run_TP_dyn_all_lanth_wind2_all_md0.052780_vd0.164316_mw0.026494_vw0.174017_mags_2020-05-26.dat --tmin 0.1 --tmax 20.0 --n 30 --err 0.25 --out pe_runs/$@_$(shell date +%Y%m%d)/ --angular-bin 5 --dist 40.0 # --GW170817-times --GW170817-loc pe_runs/$@_$(shell date +%Y%m%d)/temp/
	#rm -rf pe_runs/$@_$(shell date +%Y%m%d)/temp/
	echo "time python3 -u ${EM_PE_INSTALL_DIR}/em_pe/sampler.py --dat ./ --m kn_interp_angle -v --f g.txt --f r.txt --f i.txt --f z.txt --f y.txt --f J.txt --f H.txt --f K.txt --min 15 --max 15 --out samples.txt --fixed-param dist 40.0 --burn-in 5 --beta-start 0.001 --beta-end 0.1 --keep-npts 2000000" > pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_corner.py --posterior-samples samples.txt --out corner.png --p mej_dyn --p mej_wind --p vej_dyn --p vej_wind --p theta" > pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	echo "python3 ${EM_PE_INSTALL_DIR}/em_pe/plot_utils/plot_lc.py --log-time --posterior-samples samples.txt --out lc.png --m kn_interp_angle --tmin ${TMIN} --tmax 20.0 --lc-file g.txt --b g --lc-file r.txt --b r --lc-file i.txt --b i --lc-file z.txt --b z --lc-file y.txt --b y --lc-file J.txt --b J --lc-file H.txt --b H --lc-file K.txt --b K --fixed-param dist 40.0" > pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/sample.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_corner.sh
	chmod u+x pe_runs/$@_$(shell date +%Y%m%d)/plot_lc.sh
