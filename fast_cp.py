import os
import random
import shutil
import sys
from multiprocessing import Pool

def copy_file(file, dest_dir):
    shutil.copy(file, dest_dir)

def main():
    src_dir = sys.argv[1]
    dest_dir = sys.argv[2]
    num_files = int(sys.argv[3])
    procs = int(sys.argv[4])

    files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(src_dir) for f in filenames]
    random.shuffle(files)
    selected_files = files[:num_files]

    with Pool(processes=procs) as pool:
        pool.starmap(copy_file, [(file, dest_dir) for file in selected_files])

if __name__ == '__main__':
    main()
