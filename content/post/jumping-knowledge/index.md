---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Jumping-Knowledge Representation Learning With LSTMs"
subtitle: ""
summary: ""
authors: []
tags: [PyTorch, graph neural networks, sequence models]
categories: [machine learning]
date:   2021-02-14T23:24:17-07:00
lastmod: 2021-02-14T23:24:17-07:00
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
projects: [parcellearning]
---

## Background

As I mentioned in my previous post on [constrained graph attention networks]( {{< relref "/post/constrained-gat/index.md" >}} ), graph neural networks suffer from overfitting and oversmoothing as network depth increases.  These issues can ultimately be linked to the local topologies of the graph.

If we consider a 2d image as a graph (i.e. pixels become nodes), we see that images are highly [regular](https://en.wikipedia.org/wiki/Regular_graph) -- that is, each node has the same number of neighbors, except for those at the image periphery.  When we apply convolution kernels over node signals, filters at any given layer are aggregating information from the same-sized neighborhoods irrespective of their location.  

However, if we consider a graph, there is no guarantee that the graph will be regular.  In fact, in many situations, graphs are highly *irregular*, and are characterized by unique topological neighborhood properties such as tree-like structures or [expander graphs](https://en.wikipedia.org/wiki/Expander_graph), that are sparse yet highly connected.  If we compare an expander node to a node whose local topology is more regular, we would find that the number of signals that each node implicitly convolves at each network layer would vary considerably.  These topological discrepancies have important implications when we consider problems like node and graph classification, as well as edge prediction.  The problem ultimately boils down to one of flexibility: can we account for unique local topologies of a graph in order to dynamically aggregate local information on a node-by-node basis?

{{< figure src="InfluenceRadius.png" title="" caption="Node signal aggregation as a function of network depth.  At each layer, the neural network implicitly aggregates signals over an increasingly-larger neighborhood.  In this example, the network is highly regular -- however, not all graphs are." lightbox="true" >}}

In a recent paper, the authors propose one approach to address this question, which they call "jumping knowledge representation learning"[^1].  Instead of utilizing the output of the last convolution layer to inform the prediction, jumping-knowledge networks aggregate the embeddings from all hidden layers to inform the final prediction.  The authors develop an approach to study the "influence distribution" of nodes: for a given node $x$, the influence distribution $I_{x}$ characterizes how much the final embedding of node $x$ is influenced by the input features of every other node:

$$
\begin{align}
I(x,y) &= \sum_{i=1}^{m} |\frac{\delta h_{x}^{k}}{\delta h_{y}^{0}}|_{i} \\\\
I_{x}(y) &= I(x,y) \Big/\sum_{z} I(x,z)
\end{align}
$$

They show that influence distribution $I_{x}$ for a $k$-layer graph convolution network is equal, in expectation, to the $k$-step random walk distribution.  They point out that the random walk distribution of expander-like nodes converges quickly -- the final embeddings of these nodes are representative of the whole graph and carry global information -- while the random-walk distribution of nodes with tree-like topology converges slowly -- these nodes carry more-local information[^2].  These two conclusions are related to the spectral gap of the graph -- the smallest non-zero eigenvalue of the graph Laplacian.  A large spectral gap indicates high-connectivity, while a low spectral gap indicates low connectivity.  From a graph theory perspective, this local connectivity is related to the idea of centrality.  Nodes with high centrality will easily saturate their random walk distribution, but will also aggregate information from large neighborhoods quickly.  For graph neural networks with fixed aggregation kernels, this has important implications for representation learning, because the feature distributions of nodes with different topologies will not correspond to the same degree of locality, which may not lead to the best learned representations for all nodes.  A radius that is too large may result in over-smoothing of node features, while a radius that is too small may not be robust enough to learn optimal node embeddings.

The jumping knowledge network architecture is conceptually similar to other graph neural networks, and we can, in fact, simply incorporate the jumping knowledge mechanism as an additional layer.  The goal is to adaptively learn the effective neighborhood size on a node-by-node basis, rather than enforcing the same aggregation radius for every node (remember, we want to account for local topological and feature variations).  The authors suggest three possible aggregation functions: concatenation, max-pooling, and an LSTM-attention mechanism [^1] [^3].  Each aggregator learns an optimal combination of the hidden embeddings, which is then pushed through a linear layer to generate the final network output.  Concatenation determines the optimal linear combination of hidden embeddings for the entire dataset simultaneously, so it is not a node-specific aggregator.  Max-pooling selects the most important hidden layer for each feature element on a node-by-node basis -- however, empirically, I found that max-pooling was highly unstable in terms of model learning.  The LSTM-attention aggregator treats the hidden embeddings as a sequence of elements, and assigns a unique attention score to each hidden embedding [^4].

{{< figure src="JKGAT_LSTM.png" title="" caption="Schematic of a jumping-knowledge network.  The neural network generates an embedding for each hidden layer.  The aggregator function then optimally combines these hidden embeddings to learn the optimal abstraction of input information.  Some alternative aggregation functions include max-pooling, concatenation, and an LSTM layer.  In the case of an LSTM layer coupled with an attention mechanism, the aggregator computes a convex combination of hidden embeddings." lightbox="true" >}}

#### Long-Short Term Memory

Briefly, given a sequence of samples $X_{1}, X_{2}, \dots X_{t}$, the LSTM cell learns temporal dependencies between elements of a sequence by maintaining a memory of previously observed elements -- in our case, the sequence elements are the embeddings learned by each consecutive hidden layer.  An LSTM cell is characterized by three gates controlling information flow between elements in the sequence: input, forget, and output, as well as a cell state vector, which captures the memory and temporal dependencies between sequence elements[^5]:

{{< figure src="LSTM_cell.png" title="" caption="Schematic of an LSTM cell.  The cell controls what information is remembered from previous elements in a sequence, and what information is incorporated into memory given a new element in the sequence." lightbox="true" >}}

$$
\begin{align}
f_{t} &= \sigma(W_{f}X_{t} + U_{f}h_{t-1} + b_{f}) \\\\
i_{t} &= \sigma(W_{i}X_{t} + U_{i}h_{t-1} + b_{i}) \\\\
o_{t} &= \sigma(W_{o}X_{t} + U_{o}h_{t-1} + b_{o}) \\\\
\end{align}
$$

where $W$, $U$, and $b$ are learnable parameters of the gates.  Here, $X_{t}$ is the $t$-th sequence element, $h_{t-1}$ represents the learned LSTM cell embedding for element $t-1$, and $C_{t-1}$ represents the current memory state, given the previous $1, 2 \dots t-1$ elements.  The input and forget gates determine which aspects of a sequence element are informative / uninformative, and decide what information to keep / forget, while the output gate combines the previous memory state with our new knowledge.  We can roughly think of this process as updating our prior beliefs, in the Bayesian sense, with new incoming data.

$$
\begin{align}
\tilde{c_{t}} &= \sigma(W_{c}X_{t} + U_{c}h_{t-1} + b_{c}) \\\\
c_{t} &= f_{t}\circ c_{t-1} + i_{t} \tilde{c}_{t} \\\\
h_{t} &= o_{t} \circ tanh(c_{t})
\end{align}
$$

The embeddings for each element learned by the LSTM cell are represented by $h_{t}$.  In the original paper[^1], the authors propose to apply a bi-directional LSTM to simultaneously learn forwards and backwards embeddings, which are concatenated and pushed through a single-layer perceptron to compute layer-specific attention weights for each node:

$$
\begin{align}
\alpha_{i}^{t} &= \sigma(\vec{w}_{t}^{T}(h^{F}_{i, t} || h^{B}_{i, t})) \\\\
\alpha_{i}^{t} &= \frac{\exp{(\alpha_{i}^{t})}}{\sum_{t=1}^{L} \exp{(\alpha_{i}^{t})}}
\end{align}
$$

The softmax-normalized attention weights represent a probability distribution over attention weights

$$\begin{align}
\sum_{t=1}^{L} \alpha_{i}^{t} &= 1 \\\\
\\\\
\alpha_{i}^{t} &>= 0
\end{align}
$$

where $\alpha_{i}^{t}$ represents how much node $i$ attends to the embedding of hidden layer $t$.  The optimal embedding is then computed as the attention-weighted convex combination of hidden embeddings:

$$
\begin{align}
X_{i, \mu} = \sum_{t=1}^{L} \alpha_{i}^{t}X_{i, t}
\end{align}
$$



## An Application of Jumping Knowledge Networks to Cortical Segmentation

I've implemented the jumping knowledge network using DGL [here](https://github.com/kristianeschenburg/parcellearning/blob/master/parcellearning/jkgat/jkgat.py).  Below, I'll demonstrate the application of jumping knowledge representation learning to a cortical segmentation task.  Neuroscientifically, we have reason to believe that the influence radius will vary along the cortical manifold, even if the mesh structure is highly regular.  As such, I am specifically interested in examining the importance that each node assigns to the embeddings of each hidden layer.  To that end, I utilize the LSTM-attention aggregator.  Similarly, as the jumping-knowledge mechanism can be incorporated as an additional layer to any general graph neural network, I will use graph attention networks (GAT) as the base network architecture, and compare vanilla GAT performance to GATs with a jumping knowledge mechanism (JKGAT).

Below, I show the prediction generated by a 9-layer JKGAT model, with 4 attention heads and 32 hidden channels per layer, with respect to the "known" or "true" cortical map.  We find slight differences in the performance of our JKGAT model with respect to the ground truth map, notably in the lateral occipital cortex and the medial prefrontal cortex.

{{< figure src="prediction_G.png" title="Comparison of the group-average predicted cortical segmentation produced by the JKGAT model, to the ground truth cortical segmentation.  The ground truth was previously generated [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4990127/).  The consensus cortical map corresponds very well to the true map." caption="" lightbox="true" >}}

When we consider the accuracies for various parameterizations of our models, we see that the JKGAT performs quite well.  Notably, it performs better than the GAT model in most cases.  Likewise, as hypothesized, the JKGAT performs better than the GAT model as network depth increases, specifically because we are able to dynamically learn the optimal influence radii for each node, rather than constraining the same radius size for the entire graph.  This allows us to learn more abstract representations of the input features by mitigating oversmoothing and by accounting for node topological variability, which is important for additional use-cases like graph classification.

{{< figure src="validation.accuracy.png" title="" caption="Model accuracy comparison between GAT and JKGAT models on a node classification problem for cortical segmentation.  Accuracy is represented as the fraction of correctly-labeled nodes in a graph, across 150 validation subjects.  Each node in the graph has 80 features, and each graph has 30K nodes." lightbox="true" >}}

Similarly, we find that JKGAT networks generate segmentation predictions that are more reproducible and consistent across resampled datasets.  This is important, especially in the case where we might acquire data on an individual multiple times, and want to generate a cortical map for each acquisition instance.  Unless an individual suffers from an accelerating neurological disorder, experiences a traumatic neurological injury, or the time between consecutive scans is very long (on the order of years), we expect the cortical map of any given individual to remain quite static (though examining how the "map" of an individual changes over time is still an open-ended topic).

{{< figure src="validation.reproducibility.png" title="" caption="Model reproducibility comparison between GAT and JKGAT models on a node classification problem for cortical segmentation, using 150 validation subjects.  Each subject has four repeated datasets.  Within a given subject, the topology of each graph is the same, but the node features are re-sampled for each graph.  Reproducibility is computed using the F1-score between all pairs of predicted node classifications, such that we compute 6 F1 scores for each subject." lightbox="true" >}}

Finally, when we consider the importance that each cortical node assigns to the unique embedding at the $k$-th layer via the LSTM-attention aggregation function, we see very interesting results.  Notably, we see high spatial auto-correlation of the attention weights.  Even more striking is that this spatial correlation seems to correspond to well-studied patterns of resting-state networks identified using functional MRI. Apart from the adjacency structure of our graphs, we do not encode any *a priori* information of brain connectivity.  That the LSTM-attention aggregator of the jumping-knowledge layer identifies maps corresponding reasonably well to known functional networks of the human brain is indicative, to some extent, of how the model is learning, and more importantly, of which features are useful in distinguishing cortical areas from one another.  

Let us consider the attention map for layer 4.  We can interpret the maps as follows: for a given network architecture (in this case, a network with 9 layers), we find that areas in the primary motor (i.e. Brodmann areas 3a and banks of area 4) and primary auditory cortex (Brodmann areas A1 and R1) preferentially attend to the embedding of hidden layer 4, relative to the rest of the cortex -- this indicates that the implicit aggregation over an influence radius of 4 layers is deemed more informative for the classification of nodes in the primary motor and auditory regions than for other cortical areas.  However, whether this says anything about the implicit complexity of the cortical signals of these areas remains to be studied.

{{< figure src="attentions.png" title="" caption="Maps of learned LSTM-attention aggregator weights.  Each inset corresponds to the weights learned by every cortical node for the $k$-th layer hidden embedding (black: low, red: high).  We see that most of the attention mass is distributed over layers 4-7, indicating that most nodes assign maximal importance to intermediate levels of abstraction.  However, we do see spatially varying attention.  Notably, within a given attention map, we find that nodes of the lateral Default Mode Network preferentially attend to the embeddings of layers 1-3, while layer 4 is preferentially attended to by the primary motor and auditory areas." lightbox="true" >}}

[^1]: Xu et al. [Representation Learning on Graphs with Jumping Knowledge Networks](https://arxiv.org/pdf/1806.03536.pdf). 2018.

[^2]: Dinitz et al. [Large Low-Diameter Graphs are Good Expanders](https://arxiv.org/pdf/1611.01755.pdf). 2017.

[^3]: Lutzeyer et al. [Comparing Graph Spectra of Adjacency and Laplacian Matrices](https://arxiv.org/pdf/1712.03769.pdf). 2017.

[^4]: Gers, Felix.  [Long Short-Term Memory in Recurrent Neural Networks](http://www.felixgers.de/papers/phd.pdf). 2001.

[^5]: Fan et al. [Comparison of Long Short Term Memory Networks and the Hydrological Model in Runoff Simulation](https://www.mdpi.com/2073-4441/12/1/175/htm).  2020.
