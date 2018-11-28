from __future__ import print_function
import numpy as np
import matplotlib.pyplot as plt
import corner
import argparse

def parse_command_line_args():
    parser = argparse.ArgumentParser(description='Generate corner plot from posterior samples')
    parser.add_argument('--posterior_samples', action='append', help='File with posterior samples')
    parser.add_argument('--truth_file', help='File with true parameter values')
    parser.add_argument('--out', help='File to save plot to')
    return parser.parse_args()

def generate_plot(args):
    sample_files = args.posterior_samples
    truth_file = args.truth_file
    if truth_file is not None:
        truths = np.loadtxt(truth_file)
    else:
        truths = None
    fig_base = None
    for file in sample_files:
        samples = np.loadtxt(file, skiprows=1)
        with open(file) as f:
            header = f.readline().strip().split(' ')
        param_names = header[4:]
        L = samples[:,0]
        p = samples[:,1]
        p_s = samples[:,2]
        n, m = samples.shape
        x = samples[:,range(3, m)]
        weights = L * p / p_s
        fig_base = corner.corner(x, weights=weights, fig_base=fig_base, labels=param_names, truths=truths)
    plt.savefig(args.out)

if __name__ == '__main__':
    args = parse_command_line_args()
    generate_plot(args)
