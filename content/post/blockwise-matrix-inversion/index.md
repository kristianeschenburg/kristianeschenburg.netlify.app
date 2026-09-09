---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Blockwise Matrix Inversion"
subtitle: ""
summary: ""
authors: []
tags: [linear algebra, matrix inversion, Gauss-Markov, statistics]
categories: [mathematics]
date:   2018-05-08T23:24:17-07:00
lastmod: 2018-06-08T23:24:17-07:00
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

I'm taking a Statistics course on the theory of linear models, which covers Gauss-Markov models and various extensions of them.  Sometimes, when dealing with partitioned matrices, and commonly Multivariate Normal Distributions, we'll often need to invert matrices in a blockwise manner.  This has happened often enough during this course (coincidentally was necessary knowledge for a midterm question), so I figured I should just document some of the inversion lemmas.

Let's define our partitioned matrix as

$$ R = \\begin{bmatrix}
A & B \\\\
C & D
\\end{bmatrix}$$

We are specifically interested in finding

$$ R^{-1} = \\begin{bmatrix}
W & X \\\\
Y & Z
\\end{bmatrix}$$

such that

$$ R R^{-1} = R^{-1}R =
\\begin{bmatrix}
I & 0 \\\\
0 & I
\\end{bmatrix}$$


**Part 1: $R R^{-1}$**

For the right inverse ($R R^{-1}$), we can define

$$ \\begin{aligned}
AW + BY = I \\\\
AX + BZ = 0 \\\\
CW + DY = 0 \\\\
CX + DZ = I \\\\
\\end{aligned}
$$

and, assuming $A$ and $D$ are invertible,

$$\\begin{aligned}
X = -A^{-1}BZ \\\\
Y = -D^{-1}CW \\\\
\\end{aligned}$$

We can plug these identities back into the first system of equations as

$$\\begin{aligned}
AW + B(-D^{-1}CW) &= (A - BD^{-1}C)W = I \\\\
C(-A^{-1}BZ) + DZ &= (D - CA^{-1}B)Z = I \\\\
\\end{aligned}$$

so that

$$\\begin{aligned}
W = (A-BD^{-1}C)^{-1} \\\\
Z = (D-CA^{-1}B)^{-1} \\\\
\\end{aligned}$$

and finally

$$ R^{-1} = \\begin{bmatrix}
W & X \\\\
Y & Z
\\end{bmatrix}
= \\begin{bmatrix}
(A-BD^{-1}C)^{-1} & -A^{-1}B(D-CA^{-1}B)^{-1} \\\\
-D^{-1}C(A-BD^{-1}C)^{-1} & (D-CA^{-1}B)^{-1} \\\\
\\end{bmatrix}$$

It is important to note that the above result only holds if $A$, $D$, $(D-CA^{-1}B)$, and $(A-BD^{-1}C)$ are invertible.

**Part 2: $R^{-1} R$**

Following the same logic as above, we have the following systems of equations for the left inverse ($R^{-1}R$)

$$\\begin{aligned}
WA + XC = I \\\\
WB + XD = 0 \\\\
YA + ZC = 0 \\\\
YB + ZD = I \\\\
\\end{aligned}$$

so that

$$\\begin{aligned}
X = WBD^{-1} = A^{-1}BZ \\\\
Y = ZCA^{-1} = D^{-1}CW \\\\
\\end{aligned}$$

which indicates that

$$\\begin{aligned}
W = (A-BD^{-1}C)^{-1} = C^{-1}D(D-CA^{-1}B)^{-1}CA^{-1} \\\\
X = (A-BD^{-1}C)^{-1}BD^{-1} = A^{-1}B(D-CA^{-1}B)^{-1} \\\\
\\end{aligned}$$

Importantly, blockwise matrix inversion allows us to define the inverse of a larger matrix, with respect to its subcomponents.  Likewise, from here, we can go on to derive the Sherman-Morrison formula and Woodbury theorem, which allow us to do all kinds of cool stuff, like rank-one matrix updates.  In the next few posts, I'll go over a few examples of where blockwise matrix inversions are useful, and common scenarios where rank-one updates of matrices are applicable.