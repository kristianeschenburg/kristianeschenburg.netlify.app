---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Distances Between Subspaces"
subtitle: ""
summary: ""
authors: []
tags: [subspaces, distance metrics]
categories: [mathematics]
date: 2020-06-24T15:27:11-07:00
lastmod: 2020-06-24T15:27:11-07:00
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: yes

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [submet]
---

I'm working with some multi-dimensional float-valued data -- I'll call a single instance of this data $X \in \mathbb{R}^{n \times k}$.  I have multiple samples $X_{1}, X_{2}...X_{t}$, and want to compare these subspaces -- namely, I want to compute the distance between pairs of subspaces.

Let's assume that our subspaces are not rank-deficient -- i.e. for a given subspace sample, all of our dimensions are linearly independent.  Thus, the $k$ vectors form a basis set that spans some $k$-d subspace in $\mathbb{R}^{n}$.  We can think of each $k$-d subspace as a hyperplane in $(k+1)$-d space, just as we can think of a 2-d plane in 3-d space.  One way to compare these subspaces is by using the "principal angles between subspaces" (or [angles between flats](https://en.wikipedia.org/wiki/Angles_between_flats)).  We can compare the "angles" between these hyperplanes, which will tell us how "far apart" the two subspaces are.

{{< figure src="subspaces.png" title="" caption="Intersecting 2D linear [subspaces](https://www.researchgate.net/publication/327930102_Optimal_Exploitation_of_Subspace_Prior_Information_in_Matrix_Sensing)." lightbox="true" >}}


This comparison is effectively based on the [QR decomposition](https://en.wikipedia.org/wiki/QR_decomposition) and the [Singular Value Decomposition](https://en.wikipedia.org/wiki/Singular_value_decomposition).  For two subspaces $[U, W]$, we compute the QR decomposition of both:

$$\begin{align}
U &= Q_{u}R_{u}\\\\
W &= Q_{w}R_{w}\\\\
\end{align}$$

where $Q_{u}$ and $Q_{w} \in \mathbb{R}^{n \times k}$ are orthonormal bases such that $Q_{u}^{T}Q_{u} = Q_{w}^{T}Q_{w} = I_{k}$ that span the same subspace as the original columns of $U$ and $W$, and $R_{u}$ and $R_{w} \in \mathbb{R}^{k \times k}$ are upper triangular matrices.  Next, we compute the matrix $D = \langle Q_{u}, Q_{w} \rangle = Q_{u}^{T} Q_{w} \in \mathbb{R}^{k \times k}$, and then apply the singular value decomposition:

$$\begin{align}
D = USV^{T}
\end{align}$$

We can sort of think of $D$ as the cross-covariance matrix.  As such, the singular vectors represent the main orthogonal axes of cross-covariation between our two subspaces, while the singular values represent angles.  In order to compute the principal angles of our subspaces, we simply take 

$$\begin{align}
\theta &= cos^{-1}(S) \\\\
&=cos^{-1}[\sigma_{1}, \sigma_{2}...\sigma_{k}]
\end{align}$$

which gives us the principal angles (in radians).  Because the SVD is invariant to sign (+/-), the principal angles range between $\Big[0, \frac{\pi}{2}\Big]$.  This means that subspaces that span the same space have a principal angle of 0, and subspaces that are orthogonal (maximally far apart) to one another have a principal angle of $\frac{\pi}{2}$.

In order to compute the "distance" between our subspaces, we can apply [various metrics](https://galton.uchicago.edu/~lekheng/work/schubert.pdf) to our vector of principal angles.  The simplest approach is to apply the $L2$ norm to our vector of principal angles, $\theta$, as

$$\begin{align}
d(X_{i}, X_{j}) = \sqrt{\sum_{n=1}^{k} cos^{-1}(\sigma_{n})^{2}}
\end{align}$$

This metric is called the [Grassmann Distance](http://www.eeci-institute.eu/GSC2011/Photos-EECI/EECI-GSC-2011-M5/book_AMS.pdf) and is formally related to the geodesic distance between subspaces distributed on the Grassmannian manifold.  

{{< figure src="grassmann.png" title="" caption="Grassmann manifold and its [tangent space](https://deepai.org/publication/automatic-recognition-of-space-time-constellations-by-learning-on-the-grassmann-manifold-extended-version)." lightbox="true" >}}


This, however, is a topic for another future blog post.  There are a variety of metrics we can use to compute the pairwise distance between subspaces, some of which are

 * Asimov: $\\; max(\theta)$
 * Fubini-Study:  $\\; cos^{-1}(\prod sin(\theta))$
 * Spectral:  $\\; 2 sin(\frac{max(\theta)}{2})$
 
but all are fundamentally based on some function of our vector of principal angles, $\theta$.