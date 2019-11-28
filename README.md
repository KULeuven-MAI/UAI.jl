# UAI-Julia.jl

This is a Julia library accompanying the KUL course Uncertainty in Artificial Intelligence

## Features

- Generating pseudo random, normalized tensors.
- Testing normalization of a tensor.
- Normalizing tensors overall.
- Normalizing tensors with a condition set.
- Mermaid-JS like easy, human-and-machine readable graphical model construction. e.g.:
	- c is a collider of a and b `a>c<b`
	- `a-b-c` is a linear (Markov) chain
- Displaying (factor) graphs, Hidden Markov Models, (di)graphical models


### Plots 


#### Bayesian Network - Collider

`drawFromStr("a>c<b", "plots/collider.png")`
![](plots/collider.png)

#### Bayesian Network - Fork
`drawFromStr("a<f>b", "plots/fork.png")`
![](plots/fork.png)

#### Bayesian Network - Chain
`drawFromStr("a>b>c", "plots/chain.png")`
![](plots/chain.png)

#### Markov Network - A grid with a loop 
`drawFromStr("a-b-c-d-a", "plots/grid.png")`
![](plots/grid.png)

## In progress Features

- Mixed model representations e.g. `a-b-c; e<b>d` is a mixed model with a fork extending from b

## Wanted Features

- Tools for step-by-step probabilistic reasoning: application of definitions, Bayes rule, soft logic gates, ...
- Visualization of the simplified sum-product algorithm for non-branching graphs
- Visualization of the (Sum|Max)-Product algorithm
- Integration of [](https://arxiv.org/pdf/1911.00892.pdf) and other math-visual tools
- Interactive and visualized probabilistic problem solving challenges.
- SVG support for drawFromStr()
