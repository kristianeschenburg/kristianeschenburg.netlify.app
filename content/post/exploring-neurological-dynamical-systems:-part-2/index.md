---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Exploring Neurological Dynamical Systems: Part 2"
subtitle: ""
summary: ""
authors: []
tags: [dynamical systems, dynamic mode decomposition, linear algebra]
categories: [mathematics, neuroscience]
date: 2018-05-24T11:30:43-07:00
lastmod: 2018-05-25T11:30:43-07:00
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

In my previous post on [dynamic mode decomposition]( {{< relref "/post/exploring-neurological-dynamical-systems:-part-1/index.md" >}} ), I discussed the foundations of DMD as a means for linearizing a dynamical system[^1][^2][^3].  In this post, I want to look at a way in which we can use rank-updates to incorporate new information into the spectral decomposition of our linear operator, $A$, in the event that we are generating online measurements from our dynamical system[^4] -- see the citation below if you want a more-detailed overview of this topic along with open source code for testing this method.

Recall that we are given an initial data matrix

$$\begin{align}
X = \begin{bmatrix}
x_{n_{1},m_{1}} & x_{n_{1},m_{2}} & x_{n_{1},m_{3}} & ... \\\\
x_{n_{2},m_{1}} & x_{n_{1},m_{2}} & x_{n_{2},m_{3}} & ... \\\\
x_{n_{3},m_{1}} & x_{n_{1},m_{2}} & x_{n_{3},m_{3}} & ... \\\\
... & ... & ... & ... \\\\
\end{bmatrix}
\in R^{n \times m}
\end{align}$$

which we can split into two matrices, shifted one unit in time apart:

$$\begin{align}
X^{\ast} &=
\begin{bmatrix}
\vert & \vert & \dots & \vert \\\\
\vec{x}\_1 & \vec{x}\_2  & \dots & \vec{x}\_{m-1}  \\\\
\vert & \vert & \dots & \vert \\\\
\end{bmatrix} \in R^{n \times (m-1)} \\\\
Y &= \begin{bmatrix}
\vert & \vert & \dots & \vert \\\\
\vec{x}\_2 & \vec{x}\_3  & \dots & \vec{x}\_{m}  \\\\
\vert & \vert & \dots & \vert \\\\
\end{bmatrix} \in R^{n \times (m-1)}
\end{align}$$

and we are interested in solving for the linear operator $A$, such that

$$\begin{align}
Y = AX^{\ast}
\end{align}$$

For simplicity, since we are no longer using the full matrix, I'll just refer to $X^{\ast}$ as $X$.  In the previous post, we made the constraint that $n > m$, and that rank($X$) $\leq m < n$.  Here, however, we'll reverse this assumption, such that $m > n$, and that rank($X$) $\leq m < n$, such that $XX^{T}$ is invertible, so by multiplying both sides by $X^{T}$ we have

$$\begin{align}
AXX^{T} &= YX^{T} \\\\
A &= YX^{T}(XX^{T})^{-1} \\\\
A &= QP\_{x}
\end{align}$$

where $Q = YX^{T}$ and $P_{x} = (XX^{T})^{-1}$.  Now, let's say you observe some new data $x_{m+1}, y_{m+1}$, and you want to incorporate this new data into your $A$ matrix.  As in the previous post on [rank-one updates]( {{< relref "/post/rank-one-updates/index.md" >}} ), we saw that directly computing the inverse could potentially be costly, so we want to refrain from doing that if possible.  Instead, we'll use the Sherman-Morrison-Woodbury theorem again to incorporate our new $x_{m+1}$ sample into our inverse matrix, just as before:

$$\begin{align}
(X_{m+1}X^{T}_{m+1})^{-1} = P_{x} + \frac{P_{x}x_{m+1}x_{m+1}^{T}P_{x}}{1 + x_{m+1}^{T}P_{x}x_{m+1}}
\end{align}$$

Likewise, since we're appending new data to our $Y$ and $X$ matrices, we also have

$$\begin{align}
Y_{m+1} = \begin{bmatrix}
Y & y_{m+1} \end{bmatrix} \\\\
X_{m+1} = \begin{bmatrix} \\\\
X & x_{m+1} \end{bmatrix} \\\\
\end{align}$$

such that

$$\begin{align}
Y_{m+1} X_{m+1}^{T} &= YX^{T} + y_{m+1}x_{m+1}^{T} \\\\
&= Q + y_{m+1}x_{m+1}^{T}
\end{align}$$

which is simply the sum of our original matrix $Q$, plus a rank-one matrix.  The authors go on to describe some pretty cool "local" DMD schemes, by incorporating weights, as well as binary thresholds, that are time-dependent into the computation of the linear operator, $A$.

[^1]: P.J. Schmid. [Dynamic mode decomposition of numerical and experimental data](https://hal-polytechnique.archives-ouvertes.fr/file/index/docid/1020654/filename/DMS0022112010001217a.pdf). Journal of Fluid Mechanics 656.1. 2010.

[^2]: Tu et al. [On Dynamic Mode Decomposition: Theory And Applications](http://cwrowley.princeton.edu/papers/Tu-DMD.pdf)

[^3]: Kunert-Graf et al. [Extracting Reproducible Time-Resolved Resting State Networks Using Dynamic Mode Decomposition](https://www.frontiersin.org/articles/10.3389/fncom.2019.00075/full). Front. Comput. Neurosci. 2019.

[^4]: Zhang et al. [Online dynamic mode decomposition for time-varying systems](https://arxiv.org/abs/1707.02876). 2017.
