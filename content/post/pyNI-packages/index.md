---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Lab Meeting: pip and the Python Packaging Index"
subtitle: ""
summary: ""
authors: []
tags: [Python, packaging, neuroimaging]
categories: [software engineering]
date: 2020-06-07T10:20:09-07:00
# lastmod: 2020-06-07T10:20:09-07:00
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

What follows are the contents of part of a lab meeting presentation I gave recently.  The topic of the meeting was "Python for Neuroimaging", where I covered basic software development tools that brain imaging scientists might be interested in.


# Creating Python Packages

In this lesson, I'll show you how to build your own Python package that you can then install locally or upload to the [Python Packaging Index](https://pip.pypa.io/en/stable/) (for those of you familiar with [R](https://www.r-project.org/about.html), think [CRAN](https://cran.r-project.org/), but for Python).

I'm going to be basing a lot of the material off of this [documentation](https://packaging.python.org/tutorials/packaging-projects/), but will also show a real example using some of my own personal code.

## What are packages?

I'm sure most of you are familiar with packages and libraries already, either from Matlab, R, or Python.  Packages are basically bundles of various snippets of code, i.e. **methods**, **classes**, **scripts**, **tests** etc. that are bundled together to perform some function.  Generally (hopefully), there is coherence to what these snippets of code do -- they should interact together in some way or relate to some overarching computational goal.

Within a package, you can have different groupings of code, where each grouping does some unique or discrete computing.  These groupings are called **submodules**.  A common submodule in many packages is an **Input / Output (io)** module that will read and write data that this package interacts with or produces.  Another common submodule is often related to **plotting** the outputs of your code.  And then almost always, there are submodules that perform the brunt of the algorithmic work.  So inside modules, you'll find snippets of code that relate to the goal or concept of the module.

Think of a package as a *toolbox* with a bunch of drawers, each with a label: *wood-working*, *welding*, *gardening*, *flooring*, etc.  These drawers are submodules.  You can tell by their names that they each cover certain topics.  Each drawer contains a set of tools:  *wood-working* might contain *saw*, *nail*, *sandpaper*, *wood glue*, while *welding* might contain *solder*, *flux*, *oxygen*, *glove*.  These tools are the functions, classes, and scripts that relate to that submodule.

Overall, this toolbox performs some stuff related to construction, homebuilding, repair, and has discrete bundles of code useful for a variety of those tasks.

### Directory structure for a Python package

Here we examine the skeleton of a package.  All packages follow this basic structure.

```bash
pkg_name
|-- __init__.py
|-- LICENSE
|-- pkg_name/
|    |-- submodule_a/
|    |    |-- __init__.py
|    |    |-- a_1.py
|    |-- submodule_b/
|    |    |-- __init__.py
|    |    |-- b_1.py
|    |    |-- b_2.py
|-- README.md
|-- setup.py
|-- test/
|    |-- __init__.py
```

```__init__.py``` is a required file that allows your package to be imported.  The only ```__init__.py``` file that needs to contain anything is the highest-level file. The others can be empty, but they must exist.  Here are the contents of the highest-level ```__init__.py``` file:

```python
__all__ = [
    'a_1', 'b_1', 'b_2'
]

from .submodule_a import (a_1)
from .submodule_b import (b_1, b_2)
```

```LICENSE``` tells other users / individuals in what capacity they are allowed to use your code.

```README.md``` describes how to use your code, and often contains examples.  This is a **markdown** file, but can generally be any type of **markup** language.

```test/``` is a directory in which you would want to write [unit tests](http://softwaretestingfundamentals.com/unit-testing/) for your code.

```setup.py``` is what allows you to install your package.  It's a set of instructions that get supplied to [setuptools](https://setuptools.readthedocs.io/en/latest/) package.

```python
from setuptools import setup, find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()

 setup(
   name='pkg_name',
   version='0.1.0',
   author='Kristian M. Eschenburg',
   author_email='keschenb@uw.edu',
   packages=find_packages(),
   scripts=[],
   url="https://github.com/kristianeschenburg/pkg_name",
   license='LICENSE.txt',
   description='An awesome package that does something',
   long_description=long_description,
   install_requires=[
       "numpy"
       "pytest",
       "matplotlib",
   ],
)
```

### Compiling, installing, and uploading your package

 **1. Register on PyPi**
 
 
 Once we've done all this, we're just about ready to create our Python package and upload it to [pypi.org](https://pypi.org/).  But first, we need to create an account.  For testing purposes, we'll create a test account [here](https://test.pypi.org/), but the process is the same.
 
 After you create your account, we need to create an API token, that will allow us to upload files to either [Test PyPi](https://test.pypi.org/) or [PyPi](https://pypi.org/) (depending on what we're doing) -- the following steps are the same, regardless.  
 
 Under your Test PyPi account, click your username in the top right, go to ```Account Settings```:

{{< figure src="notebook_figures/packages/PyPi_Account.png" title="" lightbox="true" >}}
 
 Scroll down and click ```Add API Token```:

 {{< figure src="notebook_figures/packages/PyPi_Token.png" title="" lightbox="true" >}}
 
 Follow the instructions there, making sure to select "Entire Account" option under the ```Scope``` tab.  
 
 **DO NOT CLOSE THIS WINDOW WHEN THIS IS COMPLETE**
 
 Next, type 
 
 ```bash 
 cd $HOME
 touch .pypirc
 ```
 
 and using your favorite text editor, enter the following:
 
 ```txt
 [testpypi]
   repository: https://test.pypi.org/legacy/
   username = __token__
   password = pypi-***
 ```
 
 If we were creating a token for PyPi, we'd type:
 
 ```txt
 [pypi]
   repository: https://pypi.org/
   username = __token__
   password = pypi-***
 ```
 
 Close your current terminal, and open a new window to refresh your settings.  Now, when we go to upload our package to PyPi, we'll be able to type the commands without needed to supply a username and password directly.
 

 **2. Compile your package**
 
First, we need to make sure that a few Python packages are installed.  Namely, we need to install [pip](https://pip.pypa.io/en/stable/)

```bash
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install -U pip
```

Then we can install the following packages:

```bash
pip install --upgrade pip setuptools wheel # for installing Python packages
pip install tqdm # progress bar package
pip install --user --upgrade twine # for publishing to PyPi
```

Then, we can compile our package:

```bash
python setup.py bdist_wheel
```

which creates the directories ```dist```, ```build```, and ```pkg_name.egg-info```.  The ```*.egg-info``` file is basically some zipped meta-data about your package, but we're really only interested in the ```*.whl``` file in ```dist``` -- "wheels" are a "distribution" format, newly designed to replace "eggs".  I won't go into it here, but **eggs** were sort an *ad hoc* solution to packaging Python code -- **wheels** were part of [PEP427](https://www.python.org/dev/peps/pep-0427/) i.e. is actually an "enhancement" to the Python language, and the formal way of packaging Python code.

 **3. Installing your code**

We can install our code locally with:

```bash
pip install dist/pkg_name-0.0.0-py3-none-any.whl
```

If you want to install an "editable" version of your package, do this:


```bash
pip install -e .
```

This will allow you to change your ```*.py``` files and have these changes take effect immediately when importing your package, without needing to rebuild each time -- but this method installs from the **egg** distribution, and generally produces larger build files, since the build needs to keep track of your actual source code.

 **4. Upload your code**
 
We can upload our code to PyPi now using the following command:

```bash
python3 -m twine upload --repository testpypi dist/*
```

Now, if you click "Your Projects" under your account name on PyPi, you'll see that you project has been uploaded.

** I should note that, any time you want to upgrade your code and upload it to PyPi again, you need to remove all files from the ```dist``` directory, increment the ```version``` number in the ```setup.py``` file -- i.e. 0.0.0 --> 0.0.1 -- rebuild your package with

```python
bash python setup.py bdist_wheel
```

### Example with personal package

I don't generally upload my code to PyPi (probably scared bugs in the code, and people finding them, and then thinking I'm terrible at software development, and going down a long spiral of self-deprecation, but I digress...) but I do upload it all to GitHub.  In either case, here is a walk-through of packaging some software called ```pysurface``` that I use for processing mesh-based data -- I use it for adjacency matrices, performing Laplacian smoothing on surfaces, sampling points from mesh triangle simplices, plotting on surfaces...  Just some stuff that I find myself doing a lot.

Here is the directory containing all my code:

{{< figure src="notebook_figures/packages/pysurface_code.png" title="" lightbox="true" >}}

You'll see 5 different modules: ```graphs```, ```operations```, ```plotting```, ```spectra```, and ```utilities```, and you'll note that each module directory has a ```__init__.py``` file.

Here is my ```setup.py``` file:

```python
from os import path
from setuptools import setup, find_packages
import sys

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.rst'), encoding='utf-8') as readme_file:
    readme = readme_file.read()

with open(path.join(here, 'requirements.txt')) as requirements_file:
    # Parse requirements.txt, ignoring any commented-out lines.
    requirements = [line for line in requirements_file.read().splitlines()
                    if not line.startswith('#')]


setup(
    name='pysurface',
    version="0.0.4",
    description="Python package for quickly processing surface meshes.",
    long_description=readme,
    author="Kristian Eschenburg",
    author_email='keschenb@uw.edu',
    url='https://github.com/kristianeschenburg/pysurface',
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            # 'some.module:some_function',
            ],
        },
    include_package_data=True,
    package_data={
        'pysurface': [
            # When adding files here, remember to update MANIFEST.in as well,
            # or else they will not be included in the distribution on PyPI!
            # 'path/to/data_file',
            ]
        },
    install_requires=requirements,
    license="BSD (3-clause)",
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
    ],
)
```

You can see that I've run 

```bash
python setup.py bdist_wheel
```

based off the ```dist```, ```build```, and ```pysurface.egg-info``` directories.  ```dist``` contains a file called ```pysurface-0.0.4-py3-none.any.whl```, which is the actual distribution that can be used for installation.  I've uploaded the code to Test PyPi, and this is what we see:

{{< figure src="notebook_figures/packages/PyPi_Project.png" title="" lightbox="true" >}}

We can then install the package and all of it's dependencies from TestPypi via

```bash
pip install --index-url https://test.pypi.org/simple/ pysurface
```

Now I can do something like the following in a Python script:

```python
import pysurface
# or
from pysurface import graphs, spectra
# or
from pysurface.spectra import eigenspectrum
```
