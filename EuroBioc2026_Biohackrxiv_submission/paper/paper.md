---
title: 'Maintaining and refining the Tidyomics ecosystem: enhancing core packages and interoperability for EuroBioc2026'
title_short: 'Enhancing Tidyomics'
tags:
  - Bioconductor
  - bioinformatics
  - R
  - Tidyomics
authors:
  - name: Carissa Chen
    orcid: 0000-0002-9225-7086
    affiliation: 1
    role: Formal Analysis, Writing – original draft;
  - name: Marco Geigges
    orcid: 0000-0001-9071-5162
    affiliation: 2
    role: Formal Analysis, Writing – review & editing;
  - name: Jasper Spitzer
    orcid: 0000-0001-9696-2092
    affiliation: 3
    role: Formal Analysis, Writing – review & editing;
  - name: Stevie Pederson
    orcid: 0000-0001-8197-3303
    affiliation: 4
    role: Formal Analysis, Writing – review & editing, Project Administration; 
  - name: Juan Henao
    orcid: 0000-0003-0783-1432
    affiliation: 5
    role: Conceptualization, Formal Analysis, Writing – review & editing
affiliations:
  - name: Department of Statistical Sciences, University of Padova, Italy
    index: 1
  - name: Friedrich Miescher Institute for Biomedical Research, Switzerland
    index: 2
  - name: Institute for Human Genetics, University Hospital Bonn, Germany
    index: 3
  - name: Black Ochre Data Labs, Indigenous Genomics, The Kids Research Institute, Australia
    index: 4
  - name: Computational Health Center, Helmholtz Munich, Neuherberg, Germany
    index: 5
date: 29 June 2026
cito-bibliography: paper.bib
event: Eurobioc 2026
biohackathon_name: "Eurobioc 2026"
biohackathon_url: "https://bioconductor.org/developers/bioccommits/"
biohackathon_location: "Turku, Finland 2026"
group: Tidyomics community
# URL to project git repo --- should contain the actual paper.md:
git_url: https://github.com/tidyomics/tidyomicsHackathonTurku2026/
# This is the short authors description that is used at the
# bottom of the generated paper (typically the first two authors):
authors_short: Tidyomics Hackathon Team
---

# Introduction

Over the course of the EuroBioc2026 Tidyomics Hackathon, 6 scientists from various disciplines in bioinformatics came together to tackle challenges in performing omics analysis using the tidy language [@wickham2014tidy] facilitated by the Tidyomics R package [@hutchison2024tidyomics]. The aims of this hackathon were driven by the need to address the increasing fragmentation and complexity of modern omics data analysis (Figure 1). As biological datasets grow in scale and variety owing to advances in sequencing technologies that query our genomes, transcriptomes, and other molecular layers independently and in parallel, data analysis workflows are becoming increasingly complex and interconnected when handling multiple omics at once.

While the AnnData Python class [@virshup2024anndata] can be ported to the R environment through the anndataR package [@deconinck2026anndatar], there is currently limited interoperability between the tidyverse and AnnData objects to seamlessly perform statistical analyses, data wrangling, and visualization natively within R. By addressing the interoperability of anndataR within the tidyverse, we sought to mitigate these technical barriers, enabling researchers to leverage the intuitive syntax of tidy frameworks regardless of the underlying data format.

Furthermore, as the tidyomics ecosystem matures, the stabilization of core packages through rigorous bug fixes and the creation of accessible, high-quality documentation are no longer peripheral tasks but essential requirements for ensuring scientific reproducibility and lowering the barrier to entry for new researchers. These efforts ensure that the community can transition from disparate scripts toward robust, unified workflows that remain adaptable and future-proof as the bioinformatics landscape evolves.

To summarise, our team contributed to the tidyomics ecosystem by expanding interoperability for anndataR within the tidyverse, refining core package stability, and improving current documentation around typical omics analysis workflows using the tidyverse language. Our primary aims included:

1.  Developing tidy-compatible functions to manipulate [anndataR](https://github.com/orgs/tidyomics/projects/1?pane=issue&itemId=136614199&issue=tidyomics%7Ctidyomics%7C31) objects
2.  Resolving critical bugs through targeted pull requests
3.  Implementing functional enhancements to the DFplyr [@DFplyr] and [tidybulk](https://github.com/orgs/tidyomics/projects/1?pane=issue&itemId=37302106&issue=tidyomics%7Ctidybulk%7C224) packages [@mangiola2021tidybulk]
4.  Producing a comprehensive and stable vignette for `tidySingleCellExperiment` [@hutchison2024tidyomics]

Our contributions address immediate technical challenges while improving interoperability and accessibility to support continuing community-driven development and contributions.

![**Schematic representation of the Tidyomics hackathon aims.** 1. We introduced tidyAnnData to provide tidy operators for AnnData objects; 2. We fixed major bugs in information accessibility for Tidyomics core packages; 3. We updated and extended Tidyomics packages such as DFplyr and tidybulk; 4. We provide a comprehensive and concise vignette for the tidySingleCellExperiment package. This plot was created by Google Nano Banana 2.](./nanobanana2.png)

# Results

## Introducing tidyAnnData

Tidyomics aims to provide tidy operations for omics-based objects in the Bioconductor ecosystem; this provides intuitive, easy-to-use, and pipe-integrative functionalities, improving scripting development and readability [@hutchison2024tidyomics]. The recent publication of AnnData for R has extended the repertoire of possibilities, including a versatile way of manipulating single-cell and spatial data [@deconinck2026anndatar]. Although AnnData for R provides an efficient way to allocate diverse modalities in a single object, its manipulation can be difficult, overall, for new or inexperienced Python users. Therefore, extending the capabilities of Tidyomics to this R object becomes attractive to optimize their manipulation and integration into the Bioconductor ecosystem.

Here, we introduce [tidyAnnData](https://github.com/orgs/tidyomics/projects/1?pane=issue&itemId=136614199&issue=tidyomics%7Ctidyomics%7C31), an R package to provide tidy operations for anndataR objects. `select()` was chosen as the first tidyverse expression to implement. `analyze_query_scope_select.AnnData()` was created to analyze the scope of a `select()` operation based on the selected columns in AnnData objects, providing a foundation for the implementation of a `select.AnnData()` function. At present, it supports only *obs*, *var*, and *layers*, but it can be extended further. `select.AnnData()` will be the next function to be developed.

Furthermore, we have started with the implementation of the `filter()` operator; so far, this operator allows us to filter cells and genes using single logical operators. The next script snippet illustrates how applying tidy operations considerably simplifies the manipulation of an AnnData object:

```r
# Loading packages
library(dplyr)
library(anndataR)

# Creating the AnnData
adata <- AnnData(
  X = matrix(rnorm(100), nrow = 10),
  obs = data.frame(
    cell_type = factor(rep(c("A", "B"), each = 5))
  ),
  var = data.frame(
    gene_name = paste0("gene_", 1:10)
  )
)

# R base
adata[adata$obs$cell_type == "A", 
      adata$var$gene_name == "gene_1"]
#> View of InMemoryAnnData object with n_obs × n_vars = 5 × 1
#>     obs: 'cell_type'
#>     var: 'gene_name'

# Tidy approach
adata |> 
    filter(cell_type == "A") |> 
    filter(.feature = "gene_1")
#> View of InMemoryAnnData object with n_obs × n_vars = 5 × 1
#>     obs: 'cell_type'
#>     var: 'gene_name'
```

## Fixing issues in accessing information for core Tidyomics packages

As a software ecosystem, Tidyomics encompasses different R packages dedicated to providing tidy operations for the different omics-based objects from the Bioconductor open source initiative [@hutchison2024tidyomics]. Thus, different contributors and different repositories constitute the core development of this project. Although Tidyomics possesses a central GitHub repository, the trace of the official Bioconductor webpages, vignettes, and independent GitHub repositories of the main Tidyomics packages was suboptimal, hampering the access and visibility of these packages for both current and new developers. Therefore, one of the aims of this hackathon was to update the information available in the Tidyomics GitHub profile (README file) to ensure correct accessibility to (i) information about package installation, (ii) information about how to use the package, and (iii) information about the raw code of the package (Table 1).

Table: Updated information regarding core packages for the Tidyomics ecosystem.

| Package | Intro | GitHub | Description |
|--------|--|--|----------|
| [tidySummarizedExperiment](https://www.bioconductor.org/packages/release/bioc/html/tidySummarizedExperiment.html) | [Vignette](https://www.bioconductor.org/packages/release/bioc/vignettes/tidySummarizedExperiment/inst/doc/introduction.html) | [GitHub](https://github.com/stemangiola/tidySummarizedExperiment) | Tidy manipulation of SummarizedExperiment objects |
| [tidySingleCellExperiment](https://bioconductor.org/packages//release/bioc/html/tidySingleCellExperiment.html) | [Vignette](https://bioconductor.org/packages//release/bioc/vignettes/tidySingleCellExperiment/inst/doc/introduction.html) | [GitHub](https://github.com/stemangiola/tidySingleCellExperiment) | Tidy manipulation of SingleCellExperiment objects |
| [tidySeurat](https://cran.r-project.org/web/packages/tidyseurat/index.html) | [Vignette](https://stemangiola.github.io/tidyseurat/articles/introduction.html) | [GitHub](https://github.com/stemangiola/tidyseurat) | Tidy manipulation of Seurat objects |
| [tidySpatialExperiment](https://www.bioconductor.org/packages/release/bioc/html/tidySpatialExperiment.html) | [Vignette](https://william-hutchison.github.io/tidySpatialExperiment/articles/overview.html) | [GitHub](https://github.com/william-hutchison/tidySpatialExperiment) | Tidy manipulation of SpatialExperiment objects |
| [tidytof](https://bioconductor.org/packages/release/bioc/html/tidytof.html) | [Vignette](https://keyes-timothy.github.io/tidytof/) | [GitHub](https://github.com/keyes-timothy/tidytof) | Tidy manipulation of high-dimensional cytometry data |
| [plyranges](https://bioconductor.org/packages/release/bioc/html/plyranges.html) | [Vignette](https://tidyomics.github.io/plyranges/articles/an-introduction.html) | [GitHub](https://github.com/tidyomics/plyranges) | Tidy manipulation of genomics ranges |
| [plyinteractions](https://bioconductor.org/packages/release/bioc/html/plyinteractions.html) | [Vignette](https://tidyomics.github.io/plyinteractions/articles/plyinteractions.html) | [GitHub](https://github.com/tidyomics/plyinteractions) | Tidy manipulation of genomic interactions |
| [plyxp](https://www.bioconductor.org/packages/release/bioc/html/plyxp.html) | [Vignette](https://jtlandis.github.io/plyxp/articles/plyxp.html) | [GitHub](https://github.com/jtlandis/plyxp) | Data-masking-based interface to experiment data |
| [DFplyr](https://bioconductor.org/packages/DFplyr/) | [Vignette](https://www.bioconductor.org/packages//release/bioc/vignettes/DFplyr/inst/doc/example_usage.html) | [GitHub](https://github.com/jonocarroll/DFplyr) | Tidy manipulation of DataFrame objects (S4) |


## DFplyr Changes Summary

This range introduces the [1.7.1](https://github.com/jonocarroll/DFplyr/pull/26) feature set, focused on improving grouped behavior, preserving non-standard column names, and expanding count and mutate functionality.

### 1) Grouping behavior fixes

* `GroupedDataFrame` handling now supports cases with a single group (n = 1) in both print/display and group metadata retrieval paths.
* `group_data` and formatting logic no longer require more than one group before treating data as grouped.

### 2) count.DataFrame improvements

* Added support for weighted counts through the ‘wt’ argument.
* Added sort behavior for count output.
* Improved handling of grouped counting with .drop semantics.
* Reworked internal counting to better preserve:
    * non-standard column names
    * original data types where possible
    * grouped output structure
* Added internal helper for counting workflow consolidation.

### 3) Non-standard column name compatibility

* Improved behavior for *summarise*, *count*, and *grouping* paths when columns contain non-standard names (for example, names with spaces).
* `Select` evaluation now avoids variable name collisions that could occur with a column named "x".

### 4) mutate behavior enhancement

* `mutate` now explicitly supports sequential column creation, where later expressions in the same call can reference columns created earlier in that call.
* Cleanup in `mutate` internals removed legacy/commented code and simplified the execution path.

### 5) Test coverage added/updated

* Added tests for non-standard column names across *grouping*, *count*, *weighted count*, and *summarise* scenarios.
* Added tests for sequential `mutate` behavior, including grouped-data cases.

## Creation of plot_reduce_dimension() in tidybulk 

The general philosophy of the tidyverse, and by extension tidyomics, is that, as the use of ggplot2 is free, most possible agency should be left to the end user for the creation of visualisations. There is, however, one exception: a plot that cannot reasonably be created in the usual workflow, as the pipe needs to be broken. It is the general consensus to show the percentage of variance explained when showing a principal component analysis (PCA) plot; this information is contained in the object after the call to `reduce_dimensions()`, but is not readily accessible.

A [function](https://github.com/tidyomics/tidyomicsHackathonTurku2026/tree/main/tidybulk) was created that produces the relevant plot while indicating the percentage of variance covered. In its creation, a bug was discovered in the `reduce_dimensions()` code: after being called, the function reports the variance covered by each PC in a message to the user, and the reported values were wrong. The cause of this bug was identified and fixed: it was being caused by a result being piped into a chain, subset, and then re-cast into the chain completely instead of the created subset through the `.` pronoun. The resulting bug was fixed, and code legibility was improved through [PR #343](https://github.com/tidyomics/tidybulk/pull/343); the function was submitted in [PR #344](https://github.com/tidyomics/tidybulk/pull/344), but discussion is ongoing over its relevance and similar functions for staple visualisations.

## Adjusting effect sizes through DESeq’s lfcShrink in tidybulk

In the determination of differentially expressed (DE) genes, the probability of differential expression captures whether the difference between groups is greater than or equal to a specified threshold (default is 0) with a given probability. While filtering on these probabilities and corresponding effect sizes is generally accepted, ranking the individual transcripts based on these metrics is not [@zhu2019heavy]. For this reason, several methods have been developed and are readily applied; the apeglm and ashr [@zhu2019heavy] methods are implemented in the DESeq2 function `lfcShrink()` [@love2014moderated]. The goal of this project was to implement the features of `lfcShrink()` in a new function to adjust effect sizes in a tidyomics-friendly way.

The basic functionality is now [established](https://github.com/tidyomics/tidyomicsHackathonTurku2026/tree/main/tidybulk) and produces exactly matching results, but some challenges remain; currently, the input into the function is the relevant object, as well as a coefficient and/or a prefix name. With one result present, both specifications of the corresponding coefficient and its ellipsis are working as intended for both apeglm and ashr. However, when multiple results are present, the prefix argument is required and can be used to select the correct results to be shrunk. In addition, there is no guarantee that the results selected and the coefficient specified correspond to one another. There is currently no way to build in that feature without adding additional bulk to either the object or the computational load.

## Create a standardised vignette for tidy single-cell analysis

Current vignettes and workshop materials in the tidyomics repository primarily focus on demonstrating tidyverse equivalents of base R operations and visualisations. While these resources are valuable, they often lack the comprehensive explanations and methodological context needed for new researchers to understand how single-cell analyses can be performed using the tidy language from start to finish.

To address this issue, we have started writing a comprehensive [vignette](https://github.com/tidyomics/tidyomicsHackathonTurku2026/tree/main/vignette) demonstrating the utility of the `tidySingleCellExperiment` package together with established single-cell Bioconductor packages. The vignette aims to guide the user through a typical single-cell analysis workflow, from initial pre-processing, normalisation, and clustering, to cell type annotation. We are also working to include other common cell typing tasks, such as pseudotime trajectory analysis and cell-cell communication. This resource is intended to provide an accessible entry point for researchers who are familiar with tidyverse and possess a foundational understanding of single-cell RNA-sequencing analysis, but who wish to streamline their workflows using tidy principles. Using a mouse hippocampus scRNA-seq dataset as a case study, we are implementing an end-to-end analysis pipeline that aligns with the recommendations of *Orchestrating Single-Cell Analysis* (OSCA) [@amezquita2020orchestrating] while leveraging the intuitive syntax of the tidyverse. Key outcomes of this work include:

* _Tidy workflow:_ demonstrated the seamless use of `dplyr` verbs [@dplyr], `scrapper` [@lun2022powering], and ggplot2 packages for standard single-cell tasks such as data *filtering*, *normalization*, and *high-dimensional visualization*.
* _Cell phenotyping tutorial:_ extending the vignette beyond basic processing to include practical examples of trajectory analysis and cell-cell communication, bridging the gap between raw data pre-processing and advanced biological interpretation.
* _Reproducible documentation:_ developing a narrative-driven tutorial, enabling users to understand the rationale behind each analysis step while highlighting the functionality and interoperability of the `tidySingleCellExperiment` package with other Bioconductor ecosystem.

This vignette serves as a standardised resource for the Tidyomics ecosystem, lowering the technical hurdle for researchers willing to combine Bioconductor workflows and the functionalities of the tidyverse.

# Discussion

The Tidyomics Hackathon at EuroBioc2026 was a joint effort to close current gaps and provide new functionalities for the community; concretely: (i) we introduce a new R package, [tidyAnnData](https://github.com/orgs/tidyomics/projects/1?pane=issue&itemId=136614199&issue=tidyomics%7Ctidyomics%7C31), aiming to optimize AnnData object manipulation using tidyverse operations; (ii) we solved critical bugs hampering information access to the different Tidyomics core packages; (iii) we have enhanced current packages by accessing effect size calculation options through DESeq2 and plotting reduced dimensions for the [tidybulk](https://github.com/orgs/tidyomics/projects/1?pane=issue&itemId=37302106&issue=tidyomics%7Ctidybulk%7C224) package, and by overcoming column-based limitations for the DFplyr package; and (iv) we provide a concise and self-explanatory vignette for `tidySingleCellExperiment` object manipulation.

`tidyAnnData` will be a useful tool for AnnData object manipulation in R for the whole Bioconductor community; although we present here advances in two key operators, `select()` and `filter()`, major efforts are still necessary to bring in the whole set of operations provided by the tidyverse, along with tests, examples, and the remaining software development needed to make this new package available to the public.

Solving critical bugs regarding accessibility to key information about Tidyomics core packages will improve visibility and catch the attention of future new members. Furthermore, accessing specific parameters, such as effect size calculation, along with providing default visualization operations, will enhance the capabilities of `tidybulk` to perform more complex analyses. Likewise, the enhanced and updated capabilities included in the `DFplyr` package will benefit users dealing with complex operations over continuously changing omics-based R objects. Here, we want to highlight the effort of making column names generalizable, i.e., `DFplyr` working over non-standard column names, a generalizable behaviour we encourage applying to the rest of the Tidyomics packages in the near future.

We present a concise, intuitive, and detailed explanation of the functionalities provided by `tidySingleCellExperiment` in an updated vignette. This document not only provides a valuable resource for the community, with an emphasis on new users, but also represents a template for future vignette design for the Tidyomics community, as well as for vignette updates of currently developed packages in the near future.

The Tidyomics Community Hackathon at EuroBioc2026 has provided updates, extensions, revisions, and new developments that will be beneficial for the whole Bioconductor community. Thus, we extend an open invitation to researchers and developers interested in optimizing the use of omics-oriented R objects in an intuitive and easy-to-use way, boosted by tidyverse operations.

# Data availability

All the scripts generated during this hackathon are available at [https://github.com/tidyomics/tidyomicsHackathonTurku2026](https://github.com/tidyomics/tidyomicsHackathonTurku2026)


## References
