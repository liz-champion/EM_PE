# -*- coding: utf-8 -*-
'''
Plot posterior samples
----------------------
Code to plot lightcurves from posterior samples and a model.
'''

from __future__ import print_function
import numpy as np
import argparse
import sys
import matplotlib.pyplot as plt

from em_pe.models import model_dict

def _parse_command_line_args():
    '''
    Parses and returns the command line arguments.
    '''
    parser = argparse.ArgumentParser(description='Generate lightcurve plot from data or models')
    parser.add_argument('--posterior_samples', action='append', help='Posterior sample file to plot')
    parser.add_argument('--out', help='Filename to save plot to')
    parser.add_argument('--m', help='Model name')
    parser.add_argument('--tmin', type=float, help='Minimum time')
    parser.add_argument('--tmax', type=float, help='Maximum time')
    parser.add_argument('--lc_file', action='append', help='Actual lightcurve data to plot (in same order as posterior sample files)')
    parser.add_argument('--b', action='append', help='Bands to plot (in same order as posterior sample files)')
    parser.add_argument('--fixed_param', action='append', nargs=2, help='Fixed parameters')
    return parser.parse_args()

def generate_plot(sample_files, out, m, tmin, tmax, b, lc_file=None, fixed_params=None):
    n = len(sample_files)
    fig = plt.figure(figsize=(6, 2 * n))
    model = model_dict[m]()
    for i in range(n):
        fignum = str(n) + '1' + str(i + 1)
        plt.subplot(int(fignum))
        samples = np.loadtxt(sample_files[i], skiprows=1)
        with open(sample_files[i]) as f:
            ### the "header" contains the column names
            header = f.readline().strip().split(' ')
        header = header[1:]
        lnL = samples[:,0]
        p = samples[:,1]
        p_s = samples[:,2]
        ### shift all the lnL values up so that we don't have rounding issues
        lnL += abs(np.max(lnL))
        L = np.exp(lnL)
        ### calculate weights
        weights = L * p / p_s
        _, c = samples.shape
        num_samples = 100
        param_array = np.empty((num_samples, c - 3))
        for col in range(3, c):
            p = header[col]
            values = samples[:,col]
            ### get itervals of parameters
            lower = _quantile(values, 0.4, weights)
            upper = _quantile(values, 0.6, weights)
            ### randomly sample some points in this range
            param_array[:,col - 3] = np.random.uniform(lower, upper, num_samples)
        n_pts = 200
        t = np.logspace(np.log10(tmin), np.log10(tmax), n_pts)
        param_names = header[3:]
        lc_array = np.empty((num_samples, n_pts))
        for row in range(num_samples):
            params = dict(zip(param_names, param_array[row]))
            if fixed_params is not None:
                for [name, val] in fixed_params:
                    params[name] = val
            model.set_params(params, [tmin, tmax])
            dist = params['dist']
            lc_array[row] = model.evaluate(t, b[i])[0] + 5*(np.log10(dist*1e6) - 1)
        min_lc = np.amin(lc_array, axis=0)
        max_lc = np.amax(lc_array, axis=0)
        plt.plot(t, min_lc, '--', color='black')
        plt.plot(t, max_lc, '--', color='black')
        plt.fill_between(t, min_lc, max_lc, color='red', alpha=0.4)
        if lc_file is not None:
            lc = np.loadtxt(lc_file[i])
            t = lc[:,0]
            lc = lc[:,2]
            plt.scatter(t, lc)
        ax = plt.gca()
        ax.invert_yaxis()
        ax.set_xscale('log')
        plt.xlabel('Time (days)')
        plt.ylabel('AB Magnitude')
    plt.tight_layout()
    plt.savefig(out)

def _quantile(x, q, weights=None):
    '''
    Note
    ----
    This code is copied from `corner.py <https://github.com/dfm/corner.py/blob/master/corner/corner.py>`_

    Compute sample quantiles with support for weighted samples.
    Note
    ----
    When ``weights`` is ``None``, this method simply calls numpy's percentile
    function with the values of ``q`` multiplied by 100.
    Parameters
    ----------
    x : array_like[nsamples,]
       The samples.
    q : array_like[nquantiles,]
       The list of quantiles to compute. These should all be in the range
       ``[0, 1]``.
    weights : Optional[array_like[nsamples,]]
        An optional weight corresponding to each sample. These
    Returns
    -------
    quantiles : array_like[nquantiles,]
        The sample quantiles computed at ``q``.
    Raises
    ------
    ValueError
        For invalid quantiles; ``q`` not in ``[0, 1]`` or dimension mismatch
        between ``x`` and ``weights``.
    '''
    x = np.atleast_1d(x)
    q = np.atleast_1d(q)

    if np.any(q < 0.0) or np.any(q > 1.0):
        raise ValueError("Quantiles must be between 0 and 1")

    if weights is None:
        return np.percentile(x, list(100.0 * q))
    else:
        weights = np.atleast_1d(weights)
        if len(x) != len(weights):
            raise ValueError("Dimension mismatch: len(weights) != len(x)")
        idx = np.argsort(x)
        sw = weights[idx]
        cdf = np.cumsum(sw)[:-1]
        cdf /= cdf[-1]
        cdf = np.append(0, cdf)
    return np.interp(q, cdf, x[idx]).tolist()

def main():
    args = _parse_command_line_args()
    samples = args.posterior_samples
    out = args.out
    m = args.m
    tmin = args.tmin
    tmax = args.tmax
    b = args.b
    lc_file = args.lc_file
    fixed_params = args.fixed_param
    if fixed_params is not None:
        for i in range(len(fixed_params)):
            fixed_params[i][1] = float(fixed_params[i][1])
    generate_plot(samples, out, m, tmin, tmax, b, lc_file, fixed_params)

if __name__ == '__main__':
    main()