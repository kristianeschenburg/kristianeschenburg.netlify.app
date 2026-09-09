---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Constrained Graph Attention Networks"
subtitle: ""
summary: ""
authors: []
tags: [PyTorch, graph neural networks]
categories: [machine learning]
date:   2020-12-25T23:24:17-07:00
lastmod: 2020-12-25T23:24:17-07:00
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
projects: [parcellearning]
---

In their recent [paper](https://arxiv.org/abs/1910.11945), Wang et al. propose a few updates to the Graph Attention Network (GAT) neural network algorithm (if you want to skip the technical bit and get to the code, click [here](#Implementation)).  Briefly, GATs are a [recently-developed](https://arxiv.org/pdf/1710.10903.pdf) neural network architecture applied to data distributed over a graph domain.  We can think of graph convolutional networks as progressively transforming and aggregating signals from within a local neighborhood of a node.  At each iteration of this process, we implicitly merge signals from larger and larger neighborhoods of the node of interest, and thereby learn unique representations of nodes that are dependent on their surroundings.

GATs incorporate the seminal idea of "attention" into this learning process.  In each message-passing step, rather than updating the features of a source-node via equally-weighted contributions of neighborhood nodes, GAT models learn an attention function -- i.e. they learn how to differentially pay attention to various signals in the neighborhood.  In this way, the algorithm can learn to focus on important signals and disregard superfluous signals.  If we consider neural networks as universal function approximators, the attention mechanism improves the approximating ability by incorporating multiplicative weight factors into the learning.

{{< figure src="attention_mechanism.png" title="" caption="Figure from [Velickovic et al](https://arxiv.org/pdf/1710.10903.pdf).  For a source node $i$ and destination node $j$, vectors $\vec{h_{i}}$ and $\vec{h_{j}}$ are the input feature vectors of nodes $i$ and $j$ in layer $l$.  $\mathbf{W}$ is a learned affine projection matrix.  $\mathbf{\vec{a}}$ is the learned attention function.  The source and destination node input features are pushed through the attention layer as $\alpha_{i,j} = \sigma\Big(\vec{a}^{T}\mathbf{W}\Big(\vec{h_{i}} || \vec{h_{j}}\Big)\Big)$ where $\sigma$ is an activation function, and $\alpha_{i,j}$ the unnormalized attention that node $i$ pays to node $j$ in layer $l$.  Attention weights are then passed through a softmax layer, mapping the attentions between [0,1]." lightbox="true" >}}

However, GATs are not without their pitfalls, as noted by Wang et al.  Notably, the authors point to two important issues that GATs suffer from: overfitting of attention values and oversmoothing of signals across class boundaries.  The authors propose that GATs overfit the attention function because the learning process is driven only by classification error, with complexity $O(|V|)$ i.e. the number of nodes in the graph.  With regards to oversmoothing, the authors note that a single attention layer can be viewed as a form of Laplacian smoothing:

$$\begin{align}
Y = AX^{l}
\end{align}$$

where $A_{n \times n}$ is the attention weight matrix with $A_{i,j} = \alpha_{i,j}$ if $j \in \mathcal{N_{i}}$ and $0$ otherwise.  Because $\sum_{j\in \mathcal{N_{i}}} \alpha_{i,j} = 1$, we can view $A$ as a random walk transition probability matrix.  If we assume that graph $G=(V,E)$ has $K$ connected components, repeated application of $A$ to $X$ distributed over $G$ will result in a stationary distribution of node features within each connected component -- that is, the feature vectors of the nodes within each connected component will converge on the component mean.  However, as the authors point out, we typically have multiple layers $l_{1}\dots l_{j}$, each with their own attention matrix $A_{1} \dots A_{j}$, each representing a unique transition probability matrix.  Because we generally do not have disconnected components, nodes from different classes will be connected -- consequently, deep GAT networks will mix and smooth signals from different adjacent components, resulting in classification performance that worsens with network depth.  Importantly, multi-head attention networks do not alleviate this convergence issue -- each head can be viewed as a unique probability transition matrix, which all suffer from the same oversmoothing issue as $l \rightarrow \infty$.

Wang et al. propose to incorporate two margin-based constraints into the learning process.  The first constraint, $\mathcal{L_{g}}$, addresses the overfitting issue, by enforcing that learned attentions between adjacent pairs of nodes be higher than attentions between distant pairs of nodes.  

$$\begin{align}
\mathcal{L_{g}} &= \sum_{i \in V} \sum_{j \in \mathcal{N_{i}} \setminus \mathcal{N_{i}^{-}}} \sum_{k \in V\setminus \mathcal{N_{i}}} max(0, \phi(v_{i},v_{k}) + \zeta_{g} - \phi(v_{i},v_{j}))
\end{align}$$

The second constraint, $\mathcal{L_{b}}$, addresses the oversmoothing issue, by enforcing that learned attentions between pairs of adjacent nodes with the same label be higher than attention between pairs of adjacent nodes with different labels:

$$\begin{align}
\mathcal{L_{b}} &= \sum_{i \in V}\sum_{j \in \mathcal{N_{i}^{+}}} \sum_{k \in \mathcal{N_{i}^{-}}} max(0, \phi(v_{i},v_{k}) + \zeta_{b} - \phi(v_{i},v_{j}))
\end{align}$$

In both cases, $\phi(,)$ is the attention function between a pair of nodes, $\mathcal{N_{i}^{+}}$ and $\mathcal{N_{i}^{-}}$ are the nodes adjacent to node $i$ with the same (+) and different (-) labels as $i$, and $\zeta_{g}$ and $\zeta_{b}$ are slack variables controlling the margin between attention values.  The first loss function, $\mathcal{L_{g}}$, can be implemented via negative sampling of nodes (the authors actually perform importance-based negative sampling based on attention-weighted node degrees, but showed that this only marginally improved classification accuracy in benchmark datasets).

The authors propose one final addition to alleviate the oversmoothing issue posed by vanilla GATs.  Rather than aggregating over all adjacent nodes in a neighborhood, the authors propose to aggregate over the nodes with the $K$ greatest attention values.  Because the class boundary loss $\mathcal{L_{b}}$ enforces large attentions on nodes of the same label and small attention on nodes of different labels, aggregating over the top $K$ nodes will tend to exclude nodes of different labels than the source node in the message passing step, thereby preventing oversmoothing.  The authors show that this constrained aggregation approach is preferable to attention dropout proposed in the original [GAT paper](https://arxiv.org/pdf/1710.10903.pdf).  <a name="Implementation">
Taken together, the authors deem these margin-based losses and constrained aggregation "Constrained Graph Attention Network" (C-GAT).

</a>

## Implementation

I wasn't able to find an implementation of the Constrained Graph Attention Network for my own purposes, so I've implemented the algorithm myself in [Deep Graph Library](https://www.dgl.ai/) (DGL) -- the source code for this convolutional layer can be found [here](https://github.com/kristianeschenburg/parcellearning/blob/master/parcellearning/conv/cgatconv.py).  This implementation makes use of the original DGL ```GATConv``` layer structure, with modifications made for the constraints and aggregations.  Specifically, the API for ```CGATConv``` has the following modifications:

```python

CGATCONV(in_feats, 
         out_feats, 
         num_heads, 
         feat_drop=0., 
         graph_margin=0.1, # graph structure loss slack variable
         class_margin=0.1, # class boundary loss slack variable
         top_k=3, # number of messages to aggregate over
         negative_slope=0.2,
         residual=False,
         activation=None,
         allow_zero_in_degree=False)
```

Of note is the fact that the ```attn_drop``` parameter has been substituted by the ```top_k``` parameter in order to mitigate oversmoothing, and the two slack variables $\zeta_{g}$ and $\zeta_{b}$ are provided as ```graph_margin``` and ```class_margin```.  

With regards to the loss functions, the authors compute all-pairs differences between all edges incident on a source node, instead of summing over the positive / negative sample attentions ($\mathcal{L_{g}}$) and same / different label attentions ($\mathcal{L_{b}}$) and then differencing these summations.  In this way, the C-GAT model anchors the loss values to specific nodes, promoting learning of more generalizable attention weights.  The graph structure loss function $\mathcal{L_{g}}$ is implemented with the ```graph_loss``` reduction function below:

```python
def graph_loss(nodes):
            
    """
    Loss function on graph structure.
    
    Enforces high attention to adjacent nodes and 
    lower attention to distant nodes via negative sampling.
    """

    msg = nodes.mailbox['m']

    pw = msg[:, :, :, 0, :].unsqueeze(1)
    nw = msg[:, :, :, 1, :].unsqueeze(2)

    loss = (nw + self._graph_margin - pw).clamp(0)
    loss = loss.sum(1).sum(1).squeeze()

    return {'graph_loss': loss}
.
.
.
graph.srcdata.update({'ft': feat_src, 'el': el})
graph.dstdata.update({'er': er})
graph.apply_edges(fn.u_add_v('el', 'er', 'e'))
e = self.leaky_relu(graph.edata.pop('e'))

# construct the negative graph by shuffling edges
# does not assume a single graph or blocked graphs
# see cgatconv.py for ```construct_negative_graph``` function
neg_graph = [construct_negative_graph(i, k=1) for i in dgl.unbatch(graph)]
neg_graph = dgl.batch(neg_graph)

neg_graph.srcdata.update({'ft': feat_src, 'el': el})
neg_graph.dstdata.update({'er': er})
neg_graph.apply_edges(fn.u_add_v('el', 'er', 'e'))
ne = self.leaky_relu(neg_graph.edata.pop('e'))

combined = th.stack([e, ne]).transpose(0, 1).transpose(1, 2)
graph.edata['combined'] = combined
graph.update_all(fn.copy_e('combined', 'm'), graph_loss)

# compute graph structured loss
Lg = graph.ndata['graph_loss'].sum() / (graph.num_nodes() * self._num_heads)
```

Similarly, the class boundary loss function $\mathcal{L_{b}}$ is implemented with the following message and reduce functions:

```python
def adjacency_message(edges):
            
    """
    Compute binary message on edges.

    Compares whether source and destination nodes
    have the same or different labels.
    """

    l_src = edges.src['l']
    l_dst = edges.dst['l']

    if l_src.ndim > 1:
        adj = th.all(l_src == l_dst, dim=1)
    else:
        adj = (l_src == l_dst)

    return {'adj': adj.detach()}

def class_loss(nodes):
    
    """
    Loss function on class boundaries.
    
    Enforces high attention to adjacent nodes with the same label
    and lower attention to adjacent nodes with different labels.
    """

    m = nodes.mailbox['m']

    w = m[:, :, :-1]
    adj = m[:, :, -1].unsqueeze(-1).bool()

    same_class = w.masked_fill(adj == 0, np.nan).unsqueeze(2)
    diff_class = w.masked_fill(adj == 1, np.nan).unsqueeze(1)

    difference = (diff_class + self._class_margin - same_class).clamp(0)
    loss = th.nansum(th.nansum(difference, 1), 1)

    return {'boundary_loss': loss}
.
.
.
graph.ndata['l'] = label
graph.apply_edges(adjacency_message)
adj = graph.edata.pop('adj').float()

combined = th.cat([e.squeeze(), adj.unsqueeze(-1)], dim=1)
graph.edata['combined'] = combined
graph.update_all(fn.copy_e('combined', 'm'), class_loss)
Lb = graph.ndata['boundary_loss'].sum() / (graph.num_nodes() * self._num_heads)
```

And finally, the constrained message aggregation is implemented using the following reduction function:

```python
def topk_reduce_func(nodes):
    
    `"""
    Aggregate attention-weighted messages over the top-K 
    attention-valued destination nodes
    """

    K = self._top_k

    m = nodes.mailbox['m']
    [m,_] = th.sort(m, dim=1, descending=True)
    m = m[:,:K,:,:].sum(1)

    return {'ft': m}
.
.
.
# message passing
if self._top_k is not None:
    graph.update_all(fn.u_mul_e('ft', 'a', 'm'), 
                    topk_reduce_func)
else:
    graph.update_all(fn.u_mul_e('ft', 'a', 'm'),
                    fn.sum('m', 'ft'))
```