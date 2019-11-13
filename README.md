# UAI-Julia.jl

This is a Julia library accompanying the KUL course Uncertainty in Artificial Intelligence

## Features

- Generating pseudo random, normalized tensors.
- Testing normalization of a tensor.
- Normalizing tensors overall.
- Normalizing tensors with a condition set.

## In progress Features

- Mermaid-JS like easy, human-and-machine readable graphical model construction. e.g.:
	- c is a collider of a and b `a>c<b`
	- `a-b-c` is a linear (Markov) chain
	- `a-b-c; e<b>d` is a mixed model with a fork extending from b
	- ...
- Displaying (factor) graphs, Hidden Markov Models, (di)graphical models

## Wanted Features

- Tools for step-by-step probabilistic reasoning: application of definitions, Bayes rule, soft logic gates, ...
- Visualization of the simplified sum-product algorithm for non-branching graphs
- Visualization of the (Sum|Max)-Product algorithm
- Integration of [](https://arxiv.org/pdf/1911.00892.pdf) and other math-visual tools
- Interactive and visualized probabilistic problem solving challenges.

