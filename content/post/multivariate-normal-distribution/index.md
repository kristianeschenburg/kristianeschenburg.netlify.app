---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Multivariate Normal Distribution"
subtitle: ""
summary: ""
authors: []
tags: [probability, probability distributions, Gauss-Markov, statistics]
categories: [mathematics]
date: 2018-05-12T03:14:14-07:00
lastmod: 2018-05-13T13:29:22-07:00
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


In this post, I'll be covering the basics of Multivariate Normal Distributions, with special emphasis on deriving the conditional and marginal distributions.

Given a random variable under the usual Gauss-Markov assumptions, with $y_{i} \sim N(\mu, \sigma^{2})$ with $e \sim N(0,\sigma^{2})$, and $N$ independent samples $y_{1}...y_{n}$, we can define vector $\mathbf{y} = [y_{1}, y_{2},...y_{n}] \sim N_{n}(\mathbf{\mu},\sigma^{2}I)$ with $\mathbf{e} \sim N_{n}(\mathbf{0},\sigma^{2}I)$.  We can see from the covariance structure of the errors that all off-diagonal elements are 0, indicating that our samples are independent with equal variances.

**Marginal Distributions**

Now assume that $\mathbf{y} = \[\mathbf{y_{1}}, \mathbf{y_{2}} \] \sim N(\mathbf{\mu},\Sigma)$, where $\mathbf{\mu} = \begin{bmatrix} \mu_{1} \\ \mu_{2} \end{bmatrix}$, and $\Sigma$ is an arbitrary covariance matrix, where we cannot assume independence.  If $\Sigma$ is non-singular, we can decompose $\Sigma$ as

$$ \Sigma = \begin{bmatrix}
\Sigma_{11} & \Sigma_{21}^{T} \\\\
\Sigma_{21} & \Sigma_{22}
\end{bmatrix}$$

and, using the inversion lemmas from [Blockwise Matrix Inversion]({{< relref "/post/blockwise-matrix-inversion/index.md" >}}), define its inverse $\Sigma^{-1} = V$ as

$$
V = \begin{bmatrix}
V_{11} & V_{21}^{T} \\\\
V_{21} & V_{22} \\\\
\end{bmatrix}
\begin{bmatrix}
(\Sigma_{11} - \Sigma_{12}\Sigma_{22}^{-1}\Sigma_{21})^{-1} & -\Sigma^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1} \\\\
-\Sigma_{22}^{-1}\Sigma_{21}(\Sigma_{11}-\Sigma_{12}\Sigma_{22}^{-1}\Sigma_{21})^{-1} & (\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}
\end{bmatrix}$$

From the properties of transformations of Normal random variables, we can define the marginal of $$y_{1}$$ as

$$\begin{align}
By \sim N(B\mu,B\Sigma B^{T})
\end{align}$$

where $B = \begin{bmatrix} \mathbf{I} & 0 \end{bmatrix}$ such that

$$ \begin{bmatrix} \mathbf{I} & 0 \end{bmatrix} \begin{bmatrix} \mathbf{\mu_{1}} \\ \mathbf{\mu_{2}} \end{bmatrix} = \mathbf{\mu_{1}}$$
$$\begin{bmatrix} \mathbf{I} & 0
\end{bmatrix} \begin{bmatrix}
\Sigma_{11} & \Sigma_{12} \\\\
\Sigma_{21} & \Sigma_{22}
\end{bmatrix}
\begin{bmatrix}
\mathbf{I} \\\\
0
\end{bmatrix} = \Sigma_{11}$$

so that $\mathbf{y_{1}} \sim N(\mathbf{\mu_{1}},\Sigma_{11})$.


**Conditional Distributions**

Showing the conditional distribution is a bit long-winded, so bear with me.  We are interested in finding the distribution of $y_{2}\mid y_{1}$, which we can explicitly represent as

$$\begin{align}
f_{y_{1}}(y_{2} \mid y_{1}) = \frac{f_{y_{1},y_{2}}(y_{1},y_{2})}{f_{y_{1}}(y_{1})}
\end{align}$$

Writing out the joint density for $y$, we have the following

$$\begin{align}
f(y) =  \frac{1}{(2\pi)^{n/2}\mid \Sigma \mid ^{1/2}}\exp^{(-1/2)(y-\mu)^{T}\Sigma^{-1}(y-\mu)}
\end{align}$$

Partitioning this expression up into the individual terms related to $y_{1}$ and $y_{2}$, the exponent becomes

$$ (y-\mu)^{T}V(y-\mu) = \begin{bmatrix}
y_{1} - \mu_{1} \\\\
y_{2} - \mu_{2} \end{bmatrix}^{T}
\begin{bmatrix}
V_{11} & V_{12} \\\\
V_{21} & V_{22} \end{bmatrix}
\begin{bmatrix}
y_{1} - \mu_{1} \\\\
y_{2} - \mu_{2}
\end{bmatrix}$$

Expanding this quadratic form out, we see that we end up with

$$\begin{align}
(y_{1} - \mu_{1})^{T} V_{11}^{-1}(y_{1}-\mu_{1}) + 2(y_{1}-\mu_{1})^{T}V_{12}(y_{2}-\mu_{2}) + (y_{2} - \mu_{2})^{T}V_{22}(y_{2}-\mu_{2})
\end{align}$$

Let us, for simplicity, set $z_{1} = (y_{1} - \mu_{1})$ and $z_{2} = (y_{2} - \mu_{2})$.  Substituting back in our definitions of $V_{11}$,$V_{12}$,$V_{21}$, and $V_{22}$, and using the Sherman-Morrison-Woodbury definition for $V_{11}$, we have the following

$$\begin{align}
&z_{1}^{T}(\Sigma_{11}^{-1} + \Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}\Sigma_{21}\Sigma_{11})z_{1} \\\\
&- 2z_{1}^{T}(\Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12}^{-1})^{-1})z_{2} \\\\
&+ z_{2}^{T}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1})z_{2}
\end{align}$$

which, by distribution of $z_{1}$ across the first term and splitting the second term into its two sums, we have

$$\begin{align}
&z_{1}^{T}\Sigma_{11}^{-1}z_{11} + z_{1}^{T}\Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}V_{11}^{-1}\Sigma_{12})^{-1}\Sigma_{21}\Sigma_{11}^{-1}z_{1} \\\\
&- z_{1}^{T}(\Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1})z_{2} - z_{1}^{T}(\Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1})z_{2} \\\\
&+ z_{2}^{T}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1})z_{2}
\end{align}$$


We can pull out forms $z_{1}^{T}\Sigma_{11}^{-1}\Sigma_{12}(\Sigma_{22}-\Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}$ to the left and $(\Sigma_{22}-\Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}z_{2}$ to the right and, after applying a transpose, have

$$\begin{align}
=z_{1}^{T}\Sigma_{11}^{-1}z_{11} + (z_{2} -\Sigma_{21}\Sigma_{11}^{-1}z_{1})^{T}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}(z_{2} - \Sigma_{21}\Sigma_{11}^{-1}z_{1})
\end{align}$$

Plugging the above back into our exponential term in our original density function, we see that we have a product of two exponential terms

$$\begin{align}
&\frac{1}{C_{1}} \exp(\frac{-1}{2}(z_{1}^{T}\Sigma_{11}^{-1}z_{11})) \\\\
\end{align}$$

and

$$\begin{align}
&\frac{1}{C_{2}}\exp(\frac{-1}{2}(z_{2} - z_{1}\Sigma_{11}^{-1}\Sigma_{12})^{T}(\Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12})^{-1}(z_{2} - \Sigma_{21}\Sigma_{11}^{-1}z_{1}))
\end{align}$$

where 

$$\begin{align}
C_{1} &= (2\pi)^{p/2}\mid \Sigma_{11} \mid^{1/2} \\\\
C_{2} &= (2\pi)^{q/2}\mid \Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12} \mid ^{1/2}
\end{align}$$

The first term is the marginal density of $y_{1}$ and the second is the conditional density of $y_{2} \mid y_{1}$ with conditional mean $\mu_{2\mid 1} = \mu_{2} + \Sigma_{11}^{-1}\Sigma_{12}(y_{1} - \mu_{1})$ and conditional variance $\Sigma_{2\mid 1} = \Sigma_{22} - \Sigma_{21}\Sigma_{11}^{-1}\Sigma_{12}$.

While long and drawn out, the formulas show that the conditional distribution of any subset of Normal random variables, given another subset, is also a Normal distribution, with conditional mean and variance defined by functions of the means and covariances of the original random vector.
