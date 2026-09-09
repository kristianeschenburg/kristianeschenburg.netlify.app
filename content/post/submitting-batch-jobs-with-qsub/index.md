---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Submitting Batch Jobs with qsub"
subtitle: ""
summary: ""
authors: []
tags: [HPC, bash]
categories: [software engineering]
date: 2020-05-05T14:24:17-07:00
lastmod: 2020-05-06T14:24:17-07:00
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

I'm fortunate enought to work in a lab with some high-level computing infrastructure.  We have a cluster of machines using the [Sun Grid Engine](http://bioinformatics.mdc-berlin.de/intro2UnixandSGE/sun_grid_engine_for_beginners/README.html) (SGE) software system for distributed resource management.  The other day, I was searching for how to wrap my Python scripts with ```qsub``` so that I could submit a batch of jobs to our cluster.  Eventually, I want to be able to submit jobs with dependencies between them, but we'll start here.  

Let's create an example script that computes the mean of an MRI image.  Let's call the script ```compute_mean.py```:

```python
#!/usr/bin/env python

import argparse
import nibabel as nb
import numpy as np
import pandas as pd


parser = ArgumentParser('Compute the mean of MRI, and save to CSV file.')
parser.add_argument('-i', '--input_image', help='Path to MRI image.',
    required=True, type=str)
parser.add_argument('-o', '--output_csv', help='Output CSV file.',
    required=True, type=str)

args = parser.parse_args()

# read in image
img = nb.load(args.input_image)
# get voxel-wise data
data = img.get_data()

# compute mean
mu = np.mean(data)

# save to csv
df = pd.DataFrame({'mean': [mu]})
df.to_csv(args.output_csv)
```

The first line of this script, ```#!/usr/bin/env python``` tells the script to use the local ```python``` environment.  In my case, I have a customized installation of Python, along with a bunch packages and libraries that I've written and installed that are not available for the rest of my lab (since they're still in the testing phase or just something I'm experimenting with).  This line tells the script to use *my* Python environment, rather than the default version on our servers.

We can then create a bash wrapper, let's call in ```mean_wrapper.sh``` for a single subject

```bash
#!/bin/bash
#$ -M keschenb@uw.edu
#$ -m abe
#$ -r y
#$ -o tmp.out
#$ -e tmp.err

# Compute mean of image
image=$1
output=$2

python compute_mean.py ${image} ${output}
```

The second and third line here, with the ```M``` and ```m``` parameters, tell the script to email me once it completes the processing (or if there are any errors).  And finally, we can create a wrapper that takes in a list of subjects to process, and the input and output directories, and submits each individual job to the queue using ```qsub```:


```bash
#!/bin/bash

subjects=$1
image_dir=$2
output_dir=$3

# we create a variable, as our cluster has 2 different queues to use
# this could be hardcoded though
queue_name=$4 

while read subj
do

    image_file=${image_dir}${subj}.nii.gz
    output_file=${output_dir}${subj}.csv

    qsub -q ${queue_name}.q mean_wrapper.sh ${input_image} ${output_file}

done <${subjects}
```

Here's an example output from running ```qstat``` after submitting a batch of jobs to the cluster:

{{< figure src="qsub.png" title="Example of qstat command, after submitting jobs view qsub." lightbox="true" >}}

One thing you'll notice is the column ```priority``` -- this is literally a ```priority queue``` data structure that I mentioned in my last post on the Watershed by Flooding algorithm.  Each job is submitted to the queue with a priority value assigned to it by the SGE software, and the jobs are processed in that order -- highest priority first, lowest priority last.  Your IT manager can personalize the priority values for specific users or types of jobs, such that they are given preference or moved back in line.  This represents an equitable way of distributing compute resources across users in a lab, generally using a first-come, first-serve basis, or restricting users to a certain number of nodes.
