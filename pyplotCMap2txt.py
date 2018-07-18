import matplotlib.pyplot as plt
import numpy as np
import argparse


def get_cmap(name, nVal):
    cmp = plt.get_cmap(name, nVal)
    return cmp(range(nVal))

def write_cmap(file, cmap):
#    with open(file, 'w') as f:
#        f.write('%d' % cmap)
    np.savetxt(file, cmap)

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('cmName', type=str, choices=plt.colormaps())
    ap.add_argument('-o', type=str, dest='outfile')
    ap.add_argument('-n', type=int, default=256, dest='nVal')
    
    args = ap.parse_args()
    
    if args.outfile is None:
        args.outfile = args.cmName + '.txt'

    cmp = get_cmap(args.cmName, args.nVal)

    write_cmap(args.outfile, cmp)
    