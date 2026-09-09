---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Cross-Entropy With Structure"
subtitle: ""
summary: ""
authors: []
tags: [PyTorch, loss functions, information theory]
categories: [machine learning]
date: 2020-12-09T01:12:32-07:00
lastmod: 2020-12-09T01:12:32-07:00
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

As I mentioned in my previous [post]( {{< relref "/post/gaussian-kernel-convolution/index.md" >}} ), I work with cortical surface segmentation data.  Due to the biology of the human brain, there is considerable reproducible structure and function across individuals (thankfully!).  One manifestation of this reproducibility is exemplified by the neocortex a.k.a. the thin (~2.5mm) gray matter layer of cell-bodies at the periphery of the brain.  The neocortex is well known to have local homogeneity in terms of types of neuronal cells, protein and gene expression, and large-scale function, for example.  Naturally, researchers have been trying to identify discrete delineations of the cortex for nearly 100 years, by looking for regions of local homogeneity of various features along the cortical manifold.

As in my previous post, I'm working on this problem using graph convolution networks (GCN).  Given the logits output by a forward pass of a GCN, I want to classify a cortical node as belonging to some previously identified cortical area.  Using categorical cross-entropy, we can calculate the loss of a given forward pass of the model $h(X; \Theta)$:

$$
\begin{align}
L = -\sum_{k=1}^{K} \sum_{l \in \mathcal{L}} x_{l}^{k} \cdot log(\sigma(x^{k})_{l})
\end{align}
$$

where $x^{k}$ is the output of the model for a single node, $x_{l}^{k}$ is the one-hot-encoding value of the true labels, and $\sigma$ is the softmax function.  Importantly, the cross-entropy cost is high when the probability assigned to the true label of a node is small i.e. $log(0) = \infty$, while $log(1) = 0$ -- as such, the cross-entropy tries to minimize the rate of false negatives.

However, we can incorporate more *structure* into this loss function.  As I mentioned previously, we know that the brain is highly reproducible across individuals.  In our case, we have years of biological evidence pointing to the fact that functional brain areas i.e. like the primary visual area (V1), will always be in the same anatomical location i.e. posterior occipital cortex -- and will always be adjacent to a small subset of other functionally-defined areas, like the secondary visual area (V2), for example.

{{< figure src="https://www.jneurosci.org/content/jneuro/23/10/3981/F1.large.jpg?width=800&height=600&carousel=1" title="" caption="Various maps of the primate visual cortex.  [Tootell et al, 2003](https://www.jneurosci.org/content/23/10/3981)." lightbox="true" >}}

This leads us to the idea of assigning a high cost when nodes which should be in V1, for example, are assigned labels of regions that are not adjacent to V1.  We do so by defining another cost function:

\begin{align}
G = -\sum_{k=1}^{k}\sum_{l \in \mathcal{L}} \sum_{h \in \mathcal{L} \setminus \mathcal{N_{l}}} w_{l}^{k} \cdot log(1-\sigma(x^{k})_{l})
\end{align}

where $w_{l}^{k}$ is the probability weight assigned to label $h \in \mathcal{L}\setminus \mathcal{N_{l}}$ i.e. the set of labels not adjacent to label $l$.  In order to follow the idea of a cross-entropy, we enforce the following constraints on weights $\mathbf{w}$:

$$
\begin{align}
w_{l}^{k} >&= 0 \\\\
\sum_{l \in \mathcal{L}} w_{l}^{k} &= 1
\end{align}
$$

such that the vector $\mathbf{w}$ is a probability distribution over labels.  Importantly, if we  consider more closely what this loss-function is doing, we are encouraging the predicted label of $x^{k}$ to **not** be in the set $\mathcal{L} \setminus \mathcal{N_{l}}$.  Assume, for example, that the true label of $x^{k}$ is $t$, and that label $j$ is not adjacent to label $t$ on the cortical surface.  If the softmax function assigns a probability $p(x^{k}_{l} = j) = 0.05$, then $log(1-p(x^{k}_{l} = j))$ will be small.  However, if $p(x^{k}_{l} = j) = 0.95$, then $log(1-p(x^{k}_{l} = j))$ will be large.  Consequently, we penalize higher probabilities assigned to labels not adjacent to our true label -- i.e. ones that are not even biologically plausible.  If a candidate label of $x^{k}_{l} \in \mathcal{N_{t}}$, we simply set $w_{l}^{k} = 0$ -- that is, we do not penalize the true label (obviously), or labels adjacent to the true label, since these are the regions we really want to consider.

Below, I've implemented this loss function using [Pytorch](https://pytorch.org/) and [Deep Graph Library](https://www.dgl.ai/).  Assume that we are given the adjacency matrix of our mesh, the logits of our model, and the true label of our training data:

```python
import numpy as np

import dgl
import dgl.function as fn
import torch.nn.functional as F

import torch as th

def structured_cross_entropy(graph, logits, target):
    
    """
    Compute a structured cross-entropy loss.
    
    Loss penalizes high logit probabilities assigned to labels
    that are not directly adjacent to the true label.
    
    Parameters:
    - - - - -
    graph: DGL graph
        input graph structure
    input: torch tensor
        logits from model
    target: torch tensor
        true node labeling
    Returns:
    - - - -
    loss: torch tensor
        structured cross-entropy loss
    """
    
    # compute one-hot encoding of true labels
    hot_encoding = F.one_hot(target).float()
    
    # identify adjacent labels
    weight = th.matmul(hot_encoding.t(), 
                               th.matmul(graph.adjacency_matrix(), hot_encoding))
    weight = (1-(weight>0).float())

    # compute inverted encoding (non-adjacent labels receive value of 1)
    inv_encoding = weight[target]
    # weight by 1/(# non adjacent)
    # all non-adjacent labels receive the same probability
    # adjacent labels and self-label receive probability of 0
    inv_encoding = inv_encoding / inv_encoding.sum(1).unsqueeze(1)
    loss = th.sum(inv_encoding*th.log(1-F.softmax(logits)), 1)

    return -loss.mean()
```

If we wanted to use this loss function in conjunction with another loss, like the usual cross-entropy, we could perform something like the following:

```python

# define a regularizing parameter
gamma = 0.1
# define the usual cross-entropy loss function
loss_fcn = torch.nn.CrossEntropyLoss()
loss = loss_function(logits, target) + gamma*structured_cross_entropy(graph, logits, target)

# because our new loss functions performs computations using Pytorch
# the computation history is stored, and we can compute the gradient 
# with respect to this combined loss as

optimizer.zero_grad() # zero the gradients (no history)
loss.backward() # compute new gradients
optimizer.step() # update weights and parameters w.r.t new gradient

```

Because we're optimizing two loss functions now i.e. the global accuracy of the model as defined using the conventional cross-entropy, **and** the desire for predicted labels to *not* be far away from the true label using the structured cross-entropy, this combination of loss functions will likely have the effect of slightly reducing global accuracy -- however, it will have the effect of generating predictions showing fewer anatomically spurious labels i.e. we are less likely to see vertices in the frontal lobe labeled as V1, or vertices in the lateral parietal cortex labeled as Anterior Cingulate.  Global predictions will be more biologically plausible.  While GCNs as a whole are already better able to incorporate local spatial information than other models due to the fact that they convolve signals based on the adjacency structure of the network in question, I have found empirically that these anatomically spurious predictions are still possible -- hence the need for this more-structured regularization.
