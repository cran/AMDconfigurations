# AMDconfigurations 

## Geometric detection of recurrent configurations via Average Membership Degree (AMD)

AMDconfigurations implements a geometric framework for detecting recurrent configurations in multivariate data using the Average Membership Degree (AMD). The package provides tools to:

- compute AMD curves across a range of cluster numbers
- identify the optimal number of configurations (<i>c</i><sub>opt</sub>)
- assign samples to AMD-derived configurations
- generate synthetic datasets with controlled compactness
- estimate the sigma-equivalent compactness of real data

This workflow supports analyses in transcriptomics, ecology, geohistory, finance, and any domain where the geometry of configurations reveals underlying organizational principles.

## Installation 

#### From GitHub

```
# install.packages("devtools")
devtools::install_github("yourusername/AMDconfigurations")
```

#### From CRAN (when available)

```
install.packages("AMDconfigurations")
```

## 🚀 Quick Start

```
library(AMDconfigurations)

# Example dataset
set.seed(1)
X <- matrix(rnorm(2000), ncol = 10)

# 1. Compute AMD curve
res_amd <- compute_amd_curve(
  data = X,
  its = 20,
  nin = 2,
  nsp = 10,
  verbose = TRUE,
  plot_curve = TRUE
)

# 2. Assign samples to AMD-derived configurations
res_clusters <- assign_amd_clusters(res_amd)

# 3. Estimate sigma-equivalent compactness
res_sigma <- estimate_sigma_equivalent(
  real_data = X,
  its = 20,
  nin = 2,
  nsp = 10,
  sigmas = seq(1, 10, length.out = 5)
)
```

## 🧠 Conceptual Overview
The Average Membership Degree (AMD) quantifies how sharply samples are assigned to clusters across multiple fuzzy c-means iterations.

For each number of clusters *c*, AMD measures:

- the compactness of the configuration
- the stability of membership assignments
- the geometric separation between recurrent patterns

The AMD curve typically exhibits a peak at the number of configurations that best captures the underlying structure of the data. 
This peak defines:

- <i>c</i><sub>opt</sub>: the optimal number of configurations
- AMDmax: the compactness of the real system

Synthetic datasets with controlled noise levels (*𝜎*) allow estimating the sigma-equivalent of the real data, providing a geometric measure of its intrinsic organization.

## 📘 Background
Complex-systems theory predicts that strongly coupled networks do not explore state space uniformly. Instead, trajectories tend to dwell in a limited set of recurrent regimes, often described in terms of multistability or attractor-like organisation.
When only cross-sectional data are available, this expectation becomes a geometric prediction: samples should cluster within a restricted number of high-occupancy regions of configuration space, while other regions remain sparsely populated because they correspond to intermediate or rarely visited configurations.
AMDconfigurations operationalises this idea by quantifying how sharply samples are assigned to recurrent configurations across multiple fuzzy clustering iterations. The resulting AMD curve captures the geometric definition of these high-occupancy regions without assuming any particular dynamical model.
Although the framework was originally introduced in the context of trophic structure biogeography, it generalises naturally to any multivariate system where recurrent configurations emerge.

## 🔍 Main Functions
- *compute_amd_curve()* computes the AMD curve across a range of cluster numbers.
  Returns mean, SD, and maximum AMD values, plus the estimated <i>c</i><sub>opt</sub>.

- *assign_amd_clusters()* assigns each sample to one of the AMD-derived configurations using c-means, PAM, or hierarchical clustering.

- *create_synthetic_samples()* generates synthetic clustered datasets with isotropic Gaussian noise.
  Used internally for sigma-equivalent estimation.

- *estimate_sigma_equivalent()* compares the real AMD peak to synthetic AMD peaks across noise levels to estimate the sigma-equivalent compactness of the dataset.


## 📈 Example Workflow


```
set.seed(123)

# Generate synthetic data
syn <- create_synthetic_samples(
  n_samples = 300,
  n_clusters = 4,
  std_dev = 5,
  n_dim = 10
)

# Compute AMD curve
res <- compute_amd_curve(
  data = syn,
  its = 30,
  nin = 2,
  nsp = 12,
  plot_curve = TRUE
)

# Assign clusters
res <- assign_amd_clusters(res)

# Estimate sigma-equivalent
sigma_res <- estimate_sigma_equivalent(
  real_data = syn,
  its = 30,
  nin = 2,
  nsp = 12,
  sigmas = seq(1, 15, length.out = 7),
  make_plot = TRUE
)
```

## 📚 Reference
If you use AMDconfigurations in your research, please cite:

Mendoza, M. & Araújo, M. B. (2022).  
Biogeography of bird and mammal trophic structures.  
Ecography, 45(5).

https://doi.org/10.1111/ecog.06289

##  Contributing
Contributions, suggestions, and pull requests are welcome.
Please open an issue on GitHub to report bugs or request features.

## 📄 License
MIT License.
