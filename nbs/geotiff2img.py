import glob
import os
import sys
import random
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import seaborn as sns
import numpy as np
import pandas as pd
import re
import rasterio as rio

import torch
import torchvision
from torchvision.transforms import functional
from torchvision.transforms import transforms
from labelbox import Client

from PIL import Image

def geotiff2img(img_path, layer=1, output_path=None, norm98=False):
    """ Take a GeoTIFF and process for viewing

    """
    with rio.open(img_path) as src:
        image = src.read(1)

        if norm98:
            p2, p98 = np.percentile(image, (2, 98))
            image = np.clip(image, p2, p98)
            image = (image - image.min()) / (image.max() - image.min()) 
        else:
            min_, max_ = image[image > 0].min(), image.max()
            image = np.clip((image - min_) / (max_ - min_), 0.0, 1.0)
            scale_factor = 0.5 / image[image > 0].mean() # Use mean of 0.5
            image = image * scale_factor
            image[image < 0] = -0.1
    
        if output_path:
            Path(output_path).mkdir(parents=True, exist_ok=True)
            # This regex pattern looks for .tif or .tiff at the end of the filename, case-insensitive
            filename = os.path.basename(img_path)
            pattern = r"\.tiff?$"
            # Replace with .png
            new_filename = re.sub(pattern, ".png", filename, flags=re.IGNORECASE)
            image_16bit = (image * 65535).astype(np.uint16)
            # Convert to PIL Image and save as PNG
            pil_image = Image.fromarray(image_16bit, mode='I;16')
            pil_image.save(os.path.join(output_path, new_filename))

    return image
