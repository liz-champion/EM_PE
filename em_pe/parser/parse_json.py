# -*- coding: utf-8 -*-

from __future__ import print_function
import numpy as np
import argparse
import sys
import json
from astropy.time import Time

predefined_bands = ["g", "r", "i", "z", "y", "J", "H", "K"]

def _parse_command_line_args():
    '''
    Parses and returns the command line arguments.
    '''
    parser = argparse.ArgumentParser(description='Parse Open Astronomy Catalog (OAC) JSON files')
    parser.add_argument('--t0', type=float, default=0, help='Initial time (t=0 for event)')
    parser.add_argument('--f', help='Filename for JSON file')
    parser.add_argument('--b', action='append', help='Data bands to store')
    parser.add_argument('--out', help='Directory to save data to')
    parser.add_argument('--maxpts', type=float, default=np.inf, help='Maximum number of points to keep for each band')
    parser.add_argument('--tmax', type=float, default=np.inf, help='Upper bound for time points to keep')
    parser.add_argument('--time-format', type=str, default='gps', help='Time format (MJD or GPS)')
    parser.add_argument('--telescopes', action='append', nargs='+', help='Telescopes to use (defaults to all)')
    for b in predefined_bands:
        parser.add_argument('--tmax-' + b, type=float, help="Upper bound for time in " + b + " band")
    return parser.parse_args()

def _read_data(t0, file, bands, out, maxpts, tmax, telescopes, args):
    if telescopes is not None:
        telescopes = set(telescopes)
    name = file.split('/')[-1] # get rid of path except for filename
    name = name.split('.')[0] # get event name from filename
    ### read in the data
    with open(file, "r") as read_file:
        data = json.load(read_file, encoding="UTF-8")[name]['photometry']
    ### create empty data arrays
    data_dict = {}
    for band in bands:
        data_dict[band] = np.empty((4, 0))
    for entry in data:
        if 'band' in entry:
            band = entry['band']
            ### check that it's a band we want and that it has an error magnitude
            if (band in bands and 'e_magnitude' in entry and 'telescope' in entry and 'source' in entry
                and (telescopes is None or entry['telescope'] in telescopes)
                and 'realization' not in entry):
                ### [time, time error, magnitude, magnitude error]
                to_append = np.array([[entry['time']], [0], [entry['magnitude']], [entry['e_magnitude']]]).astype(np.float)
                to_append[0] -= t0
                tmax_here = tmax
                if "tmax_" + band in args.keys() and args["tmax_" + band] is not None:
                    tmax_here = min(tmax, args["tmax_" + band])
                if to_append[0] < tmax_here:
                    data_dict[band] = np.append(data_dict[band], to_append, axis=1)
    for band in data_dict:
        data = data_dict[band]
        ### check if we have too much data
        if data.shape[1] > maxpts:
            ### basically, generate random indices, take the columns (data points)
            ### specified by those columns, and then sort them based on times
            ### (sorting is not strictly necessary but it seems like a good idea
            ### to keep data ordered)
            cols = np.random.randint(0, data.shape[1], int(maxpts))
            data = data[:,cols]
            data = data[:,data[0].argsort()]
            data_dict[band] = data
    return data_dict

def _save_data(out, data_dict):
    for band in data_dict:
        filename = out + band + '.txt'
        np.savetxt(filename, data_dict[band].T)

def _convert_time(t0):
    t = Time(t0, format='gps')
    return t.mjd

def parse_json(t0, file, bands, out, maxpts=np.inf, tmax=np.inf, gps_time=False, telescopes=None, args={}):
    '''
    Parse JSON file.

    Parameters
    ----------
    t0 : int
        Initial time (t=0) for the event
    file : string
        Name of JSON file
    bands : list
        List of names of data bands to keep
    out : string
        Directory to save data to
    maxpts : int
        Maximum number of points to keep for each band
    tmax : float
        Upper bound for time points to keep
    time_format :
    '''
    if gps_time:
        t0 = _convert_time(t0)
    data_dict = _read_data(t0, file, bands, out, maxpts, tmax, telescopes, args)
    _save_data(out, data_dict)

def main():
    args = _parse_command_line_args()
    parse_json(args.t0, args.f, args.b, args.out, args.maxpts, args.tmax, (args.time_format == 'gps'), args.telescopes, vars(args))

if __name__ == '__main__':
    main()
