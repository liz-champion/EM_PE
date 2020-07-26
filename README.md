# EM PE

Joint GW/EM parameter estimation.

More detailed documentation should be available soon.

## Installation

The integrator used for parameter estimation is implemented in RIFT.
You can install it with pip: `$ pip3 install RIFT --user` or follow the instructions [here](https://github.com/oshaughn/research-projects-RIT/blob/master/INSTALL.md).

Note: in its current form, the code expects a modified version of RIFT that's still in development.
The standard installation of RIFT will most likely not currently work.

Next, clone this repository:

```bash
$ git clone https://github.com/bwc3252/EM_PE
```

For some models, you'll need to set the `EM_PE_INSTALL_DIR` environment variable 
to the `EM_PE` install directory so that data files can be located. For example:

```bash
$ export EM_PE_INSTALL_DIR="~/Research/em_pe"
```

Then, switch to the top-level directory, and install:

```bash
$ cd EM_PE
$ python3 setup.py install --user
```

## Usage

### PE for a fake event

The Makefile provided in this repository contains the necessary setup for a few example cases.
To set up a simple injection/recovery example run `$ make test_kilonova_3c`.
This will generate fake lightcurve data using a three-component kilonova model.
The same model is then used to generate posterior samples and recover the original parameters.

Every PE run generated by the Makefile will be set up in its own directory under `pe_runs/`:

```bash
$ cd pe_runs/test_kilonova_3c
```

This directory contains a text file for each lightcurve data band used, as well as three `*.sh` scripts: `sample.sh`, `plot_corner.sh`, and `plot_lc.sh`.
The first step is to generate posterior samples:

```bash
$ ./sample.sh
```
or to run this in the background and write output to a file (`nohup.out`):
```bash
$ nohup ./sample.sh &
```

You may want to check the arguments in `sample.sh` before running it -- for example, the `--nprocs` argument specifies the number of parallel processes to use for likelihood evaluation, and should be changed depending on the machine being used.

Once this script completes, you should notice a `samples.txt` file in the run directory.
To generate a corner plot from these samples simply run `$ ./plot_corner.sh`, and to generate a lightcurve plot run `./plot_lc.sh`.
These scripts will generate .png images with the results of your PE run.

### PE for a real event

The only difference between running a real event and a fake event is that the lightcurve data must be extracted from a JSON file before running the sampler.
For convenience this repository already contains the photometry data for GW170817 and corresponding Makefile targets that handle the JSON parsing.
To set up a PE run for this event run `$ make GW170817_kilonova` to use a single-component kilonova model or `$ make GW170817_kilonova_3c` to use a three-component model.
Then follow the steps outlined above.

It should be straightforward to use the Makefile as a template for setting up other events.
It may be necessary to modify some of the sampler arguments, but the default settings should be reasonable in most cases.
