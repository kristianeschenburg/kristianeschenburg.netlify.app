---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Overview of Poisson-Multinomial Relationship"
subtitle: ""
summary: ""
authors: []
tags: [probability, probability distributions, statistics]
categories: [mathematics]
date: 2018-11-08T01:12:32-07:00
lastmod: 2018-11-09T01:12:32-07:00
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
In this post, I'm going to briefly cover the relationship between the Poisson distribution and the Multinomial distribution.  

Let's say that we have a set of independent, Poisson-distributed random variables $Y_{1}, Y_{2}... Y_{k}$ with rate parameters $\lambda_{1}, \lambda_{2}, ...\lambda_{k}$.  We can model the sum of these random variables as a new random variable $N = \sum_{i=1}^{k} Y_{i}$.

Let start with $k=2$.  We can define the distrbution of $F_{N}(n)$ as follows:

$$\begin{align}
&= P(N \leq n) \\\\
&= P(Y_{1} + Y_{2} \leq n) \\\\
&= P(Y_{1} = y_{1}, Y_{2} = n - y_{1}) \\\\
&= P(Y_{1} = y_{1}) \cdot P(Y_{2} = n-y_{1}) \\\\
&= \sum_{y_{1}=0}^{n} \frac{e^{-\lambda_{1}}\lambda_{1}^{y_{1}}}{y_{1}!} \cdot \frac{e^{-\lambda_{2}}\lambda_{2}^{n-y_{1}}}{(n-y_{1})!} \\\\
&= e^{-(\lambda_{1}+\lambda_{2})} \sum_{y_{1}=0}^{n} \frac{\lambda_{1}^{y_{1}}\lambda_{2}^{n-y_{1}}}{y_{1}!(n-y_{1})!} \\\\
&= e^{-(\lambda_{1}+\lambda_{2})} \sum_{y_{1}=0}^{n} \frac{n!}{n!}\frac{\lambda_{1}^{y_{1}}\lambda_{2}^{n-y_{1}}}{y_{1}!(n-y_{1})!} \\\\
&= \frac{e^{-(\lambda_{1}+\lambda_{2})}}{n!} \sum_{y_{1}=0}^{n} {n\choose y_{1}} \lambda_{1}^{y_{1}}\lambda_{2}^{n-y_{1}}
\end{align}$$

Here, we can apply the Binomial Theorem to the summation to get the following (remember that the Binomial Theorem says, for two numbers $x$ and $y$, that $(x+y)^{n} = \sum_{i=0}^{n} {n \choose i}x^{i}y^{n-i}$):

$$\begin{align}
\frac{e^{-(\lambda_{1}+\lambda_{2})}(\lambda_{1} + \lambda_{2})^{n}}{n!} \\\\
\end{align}$$

which we see is in fact just another Poisson distribution with rate parameter equal to $\lambda_{1} + \lambda_{2}$.  This shows that the sum of independent Poisson distributed random variables is also a Poisson random variable, with rate parameter equal to the sum of the univariate rates.  By induction, we see that for $k$ independent Poisson distributed random variables $Y_{1}...Y_{k}$, their sum $\sum_{i=1}^{k} Y_{i} \sim Poisson(\sum_{i=1}^{k} \lambda_{i})$.

Now let's say we're interested in modeling the conditional distribution of $(Y_{1}...Y_{k}) \mid \sum_{i=1}^{k} = n$.  By definition of conditional probability, we have that

$$\begin{align}
P(\bar{Y} \mid N=n) &= \frac{P(\bar{Y} \; \cap \; N=n)}{P(N=n)} \\\\
&= \frac{P(\bar{Y})}{P(N=n)}
\end{align}$$

We have the following:

$$\begin{align}
P(\bar{Y} \mid N=n) &= \frac{P(\bar{Y} \\; \cap \\; N=n)}{P(N=n)} \\\\
&= \Big( \prod_{i=1}^{k} \frac{e^{-\lambda_{i}} \cdot \lambda_{i}^{y_{i}}}{y_{i}!} \Big) \Big/ \frac{e^{-\sum_{i=1}^{k} \lambda_{i}}(\sum_{i}^{k} \lambda_{i})^{n}}{n!} \\\\
&= \Big( \frac{ e^{-\sum_{i=1}^{k}} \prod_{i=1}^{k} \lambda_{i}^{y_{i}}}{\prod_{i=1}^{k} y_{i}!} \Big) \Big/ \frac{e^{-\sum_{i=1}^{k} \lambda_{i}}(\sum_{i}^{k} \lambda_{i})^{n}}{n!} \\\\
&= { n \choose y_{1}, y_{2}, ...y_{k}} \frac{\prod_{i=1}^{k} \lambda_{i}^{y_{i}}} { \sum_{i}^{k} \lambda_{i})^{n}} \\\\
&= { n \choose y_{1}, y_{2}, ...y_{k}}  \prod_{i=1}^{k} \Big( \frac{ \lambda_{i} }{\sum_{i}^{k} \lambda_{i}} \Big)^{y_{i}} \\\\
&\sim MultiNom(n; \frac{\lambda_{1}}{\sum_{i=1}^{k}}, \frac{\lambda_{2}}{\sum_{i=1}^{k}}, ... \frac{\lambda_{k}}{\sum_{i=1}^{k}})
\end{align}$$

So finally, we see that, given the sum of independent Poisson random variables, that conditional distribution of each element of the Poisson vector is Multinomial distributed, with count probabilities scaled by the sum of the individual rates.  Importantly, we can extend these ideas (specifically the sum of independent Poisson random variables) to other models, such as splitting and merging homogenous and non-homogenous Poisson Point Processes.

