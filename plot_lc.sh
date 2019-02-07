### Basic script to plot lightcurves from data or model or both.
# Usage: sh plot_lc.sh [test name]

### Set up test data and results directory
rm -rf em_pe/tests/temp/
mkdir em_pe/tests/temp/

mkdir results/$1/

### parse JSON data
python em_pe/parser/parse_json.py --f Data/GW170817.json --out em_pe/tests/temp/ \
                                  --t0 57982.5285231481 --maxpts 50 --tmax 8 \
                                --b g \
                                --b r \
                                --b i \
                                --b z \
                                --b y \
                                --b J \
                                --b H \
                                --b K

### set up parameters file
touch em_pe/tests/temp/params.txt
#echo "0.077" >> em_pe/tests/temp/params.txt
#echo "0.095" >> em_pe/tests/temp/params.txt
echo "0.01" >> em_pe/tests/temp/params.txt # mej
echo "0.1" >> em_pe/tests/temp/params.txt # vej
#echo "0.0" >> em_pe/tests/temp/params.txt # delta_t

python em_pe/plot_utils/plot_lightcurves.py --m woko2017 --p em_pe/tests/temp/params.txt \
                                            --tmin 0.5 --tmax 8 --out results/$1/lc.png \
                                            --dat em_pe/tests/temp \
                                            --b H \
                                            --b K
