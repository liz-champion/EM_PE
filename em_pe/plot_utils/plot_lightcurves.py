# -*- coding: utf-8 -*-
'''
Plot lightcurves
----------------
Generates and saves a plot of lightcurves (from models, data, or both).

Example::

    $ python plot_lightcurve.py --dat data/ --b band --m model --p params.txt --tmin 0.1 --tmax 10 --out lc.png

To see full command line parameter documentation::

    $ python plot_corner.py -h
    usage: plot_lightcurves.py [-h] [--dat DAT] [--b B] [--m M] [--p P]
                               [--tmin TMIN] [--tmax TMAX] [--out OUT] [--div]
                               [--title TITLE]

    Generate lightcurve plot from data or models

    optional arguments:
      -h, --help     show this help message and exit
      --dat DAT      Data directory location
      --b B          Data band
      --m M          Model
      --p P          Location of parameter file
      --tmin TMIN    Minimum time (for models only)
      --tmax TMAX    Maximum time (for models only)
      --out OUT      Filename to save plot
      --div          Create plot of data/model
      --title TITLE  Custom title, overrides automatically-generated title
'''

from __future__ import print_function
import numpy as np
import matplotlib.pyplot as plt
import argparse

from em_pe.models import model_dict

def _parse_command_line_args():
    '''
    Parses and returns the command line arguments.
    '''
    parser = argparse.ArgumentParser(description='Generate lightcurve plot from data or models')
    parser.add_argument('--dat', help='Data directory location')
    parser.add_argument('--b', action='append', help='Data band')
    parser.add_argument('--m', help='Model')
    parser.add_argument('--p', help='Location of parameter file')
    parser.add_argument('--tmin', type=float, help='Minimum time (for models only)')
    parser.add_argument('--tmax', type=float, help='Maximum time (for models only)')
    parser.add_argument('--out', help='Filename to save plot')
    parser.add_argument('--div', action='store_true', help='Create plot of data/model')
    parser.add_argument('--title', help='Custom title, overrides automatically-generated title')
    return parser.parse_args()

def plot_lightcurves():
    '''
    Plots lightcurves using data, a model, or both.
    '''
    args = _parse_command_line_args()
    color_list=['black', 'red', 'orange', 'yellow', 'green', 'cyan', 'blue',
                'purple', 'gray']
    nbands = len(args.b)
    color_list = color_list[:nbands]
    color_dict = dict(zip(args.b, color_list))
    model_data = {}
    actual_data = {}
    plt.figure(figsize=(10,10))
    if args.m is not None and not args.div:
        ### we are using a model, but are NOT plotting data divided by model
        t_bounds = [args.tmin, args.tmax]
        t = np.linspace(args.tmin, args.tmax, 100)
        ### initialize model
        model = model_dict[args.m]()
        ### load the parameters
        params = np.loadtxt(args.p)
        ### match parameters to names and set them in the model
        params = dict(zip(model.param_names, params))
        model.set_params(params, t_bounds)
        for band in args.b:
            ### calculate model values in every band specified
            dat, _ = model.evaluate(t, band)
            model_data[band] = [t, dat]
    if args.dat is not None:
        ### load the data
        for band in args.b:
            actual_data[band] = np.loadtxt(args.dat + '/' + band + '.txt')
    if args.div:
        ### we are plotting data divided by model
        ### basically go through the same steps as above to initialize the model
        ### and calculate model values, but only doing so for time values that
        ### exist in the data
        t_bounds = [np.inf, -1 * np.inf]
        for band in args.b:
            real_dat = actual_data[band]
            t = real_dat[0]
            t_bounds[0] = min(t_bounds[0], min(t))
            t_bounds[1] = max(t_bounds[1], max(t))
        model = model_dict[args.m]()
        params = np.loadtxt(args.p)
        params = dict(zip(model.param_names, params))
        model.set_params(params, t_bounds)
        for band in args.b:
            t = actual_data[band][0]
            m_dat, _ = model.evaluate(t, band)
            real_dat = actual_data[band]
            plt.scatter(t, real_dat[2] / m_dat, label=band, color=color_dict[band])
    else:
        ### not dividing
        if args.m is not None:
            ### plot the model
            for band in model_data:
                dat = model_data[band]
                plt.plot(dat[0], dat[1], label=(band + ' [' + args.m + ']'), color=color_dict[band])
        if args.dat is not None:
            ### plot the data
            for band in actual_data:
                dat = actual_data[band]
                plt.scatter(dat[0], dat[2], label=band, color=color_dict[band])
    ax = plt.gca()
    if not args.div:
        ### regular lightcurve plots have their y axis inverted
        ax.invert_yaxis()
    ax.set_xscale('log')
    plt.legend()
    plt.xlabel('Time (days)')
    if args.div:
        plt.ylabel('Data / Model')
    else:
        plt.ylabel('AB Magnitude')
    ### generate title if not provided
    if args.m is not None:
        title_text = args.m + ', '
        for param_name in params:
            title_text += param_name + '='+ str(round(params[param_name], 4)) + ' '
    if args.title is not None:
        title_text = args.title
    plt.title(title_text)
    plt.savefig(args.out)

if __name__ == '__main__':
    plot_lightcurves()
