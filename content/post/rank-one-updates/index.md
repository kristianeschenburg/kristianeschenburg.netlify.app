---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Rank One Updates"
subtitle: ""
summary: ""
authors: []
tags: [linear algebra, matrix inversion]
categories: [mathematics]
date: 2018-05-11T16:53:45-07:00
lastmod: 2018-05-12T16:53:45-07:00
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

In this post, I'm going to go over some examples of rank-one updates of matrices.  To compute rank-one updates, we rely on the Sherman-Morrison-Woodbury theorem.  From the previous post on [Blockwise Matrix Inversion]({{< relref "/post/blockwise-matrix-inversion/index.md" >}}), recall that, given a matrix and its inverse

$$R = \\begin{bmatrix} 
A & B \\\\
C & D
\\end{bmatrix}  \\; \\; \\; \\; R^{-1} = \\begin{bmatrix}
W & X \\\\
Y & Z
\\end{bmatrix}$$

we have that

$$\\begin{align}
W = (A-BD^{-1}C)^{-1} = C^{-1}D(D-CA^{-1}B)^{-1}CA^{-1}
\\end{align}$$

Expanding this further, the Woodbury formula proves the following identity

$$\\begin{align}
(A+BD^{-1}C)^{-1}=A^{-1}-A^{-1}B(D−CA^{-1}B)^{-1}CA^{-1}
\\end{align}$$

Given an initial matrix $A$ and its inverse $A^{-1}$, and a new matrix $R=BD^{-1}C$, we see that we can define the inverse of our new updated matrix $A+R$ in terms of the inverse of our original matrix $A$ and components of $R$.  Importantly, we can perform rank-$k$ updates, where $rank(R) = k$.

For example, if we want to update our matrix $A$ with a new vector, $v$, we can rewrite the formula above as follows:

$$\\begin{align}
(A+vv^{T})^{-1} &=A^{-1}-A^{-1}v(1+v^{T}A^{-1}v)^{-1}v^{T}A^{-1} \\\\
&=A^{-1}-\frac{A^{-1}vv^{T}A^{-1}}{1+v^{T}A^{-1}v} \\\\
\\end{align}$$

where the updated inverse is defined so long as the quadratic form $v^{T}A^{-1}v \\neq -1$.

------
**Rank-One Updates for Linear Models**

Recall the Normal equations for linear models:

$$\\begin{align}
X^{T}X\\beta = X^{T}y
\\end{align}$$

and

$$\\begin{align}
\\beta = (X^{T}X)^{g}X^{T}y
\\end{align}$$

where $X$ is our design matrix, $y$ is our dependent variable, and $\\beta$ is a solution to the Normal equation, due to the fact that the Normal equations are consistent.  $(X^{T}X)^{g}$ is the generalized inverse of $X^{T}X$, which is unique (i.e. $(X^{T}X)^{g} = (X^{T}X)^{-1}$) only if $X$ has full column-rank.  For our immediate purpose, we assume that $X$ has full column rank.

Assume that we observe a set of observations, $X \\in R^{n \\times p}$ and response variable, $y$, and compute our coefficient estimates $\\hat{\\beta}$ via the Normal equations above, using $(X^{T}X)^{-1}$.  Now given a new observation, $v \\in R^{p}$, how can we update our coefficient estimates?  We can append $v$ to $X$ as

$$ X^{\\text{*}} = \\begin{bmatrix}
X \\\\
v
\\end{bmatrix} \\in R^{(n+1) \\times p}$$

and directly compute $(X^{\\text{\*T}}X^{\\text{\*}})^{-1}$, **or** we can use the Sherman-Morrison-Woodbury theorem:

$$
\\begin{align}
(X^{\\text{\*T}}X^{\\text{\*}})^{-1} = (X^{T}X + vv^{T})^{-1} = (X^{T}X)^{-1} - \\frac{(X^{T}X)^{-1}vv^{T}(X^{T}X)^{-1}}{1+v^{T}(X^{T}X)^{-1}v} \\\\
\\end{align}
$$

from which we can easily compute our new coefficient estimates with $$.

$$\\begin{align}
\\beta^{\\text{\*}} = (X^{\\text{\*T}}X^{\\text{\*}})^{-1}X^{\\text{\*}T}y \\\\
\\end{align}$$

Importantly, in the case of regression, for example, this means that we can update our linear model via simple matrix calculations, rather than having to refit the model from scratch to incorporate our new data.  In the next few posts, I'll go over an example of an implementation of rank-updating methods that I've been using in lab to study brain dynamics.
