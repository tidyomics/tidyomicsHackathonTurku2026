---
title: 'Maintaining and refining the tidyomics ecosystem: enhancing core packages and interoperability for EuroBioc2026'
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
    role: Formal Analysis, Writing – original draft
  - name: Marco Geigges
    orcid: 0000-0001-9071-5162
    affiliation: 2
    role: Formal Analysis, Writing – review & editing
  - name: Juan Henao
    orcid: 0000-0003-0783-1432
    affiliation: 3
    role: Conceptualization, Formal Analysis, Writing – review & editing
  - name: Michael Love
    orcid: 0000-0000-0000-0000
    affiliation: 4
    role: Conceptualization, Writing – review & editing
  - name: Stevie Pederson
    orcid: 0000-0001-8197-3303
    affiliation: 5
    role: Formal Analysis, Writing – review & editing, Project Administration
  - name: Jasper Spitzer
    orcid: 0000-0001-9696-2092
    affiliation: 6
    role: Formal Analysis, Writing – review & editing
affiliations:
  - name: Department of Statistical Sciences, University of Padova, Italy
    index: 1
  - name: Friedrich Miescher Institute for Biomedical Research, Switzerland
    index: 2
  - name: Computational Health Center, Helmholtz Munich, Neuherberg, Germany
    index: 3
  - name: Affiliation
    index: 4
  - name: Black Ochre Data Labs, Indigenous Genomics, The Kids Research Institute, Australia
    index: 5
  - name: Affiliation
    index: 6
date: 2 June 2026
cito-bibliography: paper.bib
event: Eurobioc 2026
biohackathon_name: "Eurobioc 2026"
biohackathon_url: "https://bioconductor.org/developers/bioccommits/"
biohackathon_location: "Turku, Finland 2026"
# URL to project git repo --- should contain the actual paper.md:
git_url: https://github.com/BiocCodingCollaborations/EuroBioc2026_Biohackrxiv_submission
# This is the short authors description that is used at the
# bottom of the generated paper (typically the first two authors):
authors_short: Tidyomics Hackathon Team
---

# Introduction

Over the course of the EuroBioc2026 Tidyomics Hackathon, our team contributed to the tidyomics ecosystem by refining core package stability, improving current documentation and expanding interoperability for annaDataR within the tidyverse. Our primary objectives included:

1. Implementing functional enhancements to the DFplyr and tidybulk packages
2. Resolving critical bugs through targeted pull requests
3. Developing tidy-compatible functions to manipulate annDataR objects
4. Producing a comprehensive and stable vignette for tidySingleCellExperiment

 Through these combined efforts, we have 

# Results

## Towards tidyomics for AnnData objects
In this subproject, the aim was to begin extending tidyomics to AnnData objects. select() was chosen as the first tidyverse expression to implement. analyze_query_scope_select.AnnData() was created to analyze the scope of a select() operation based on the selected columns in AnnData objects, providing a foundation for the implementation of a select.AnnData() function. At present, it supports only obs, var, and layers, but it can be extended further. select.AnnData() will be the next function to be developed.

## DFplyr Changes Summary

This range introduces the 1.7.1 feature set, focused on improving grouped behavior, preserving non-standard column names, and expanding count and mutate functionality.


### 1) Grouping behavior fixes

- GroupedDataFrame handling now supports cases with a single group (n = 1) in both print/display and group metadata retrieval paths.
- group_data and formatting logic no longer require more than one group before treating data as grouped.

### 2) count.DataFrame improvements

- Added support for weighted counts through wt.
- Added sort behavior for count output.
- Improved handling of grouped counting with .drop semantics.
- Reworked internal counting to better preserve:
  - non-standard column names
  - original data types where possible
  - grouped output structure
- Added internal helper for counting workflow consolidation.


### 3) Non-standard column name compatibility

- Improved behavior for summarise, count, and grouping paths when columns contain non-standard names (for example names with spaces).
- select evaluation now avoids variable name collisions that could occur with a column named x.


### 4) mutate behavior enhancement

- mutate now explicitly supports sequential column creation where later expressions in the same call can reference columns created earlier in that call.
- Cleanup in mutate internals removed legacy/commented code and simplified execution path.


### Test coverage added/updated

- Added tests for non-standard column names across grouping, count, weighted count, and summarise scenarios.
- Added tests for sequential mutate behavior, including grouped-data cases.




# Formatting

This document use Markdown and you can look at [this tutorial](https://www.markdowntutorial.com/).

## Subsection level 2

Please keep sections to a maximum of only two levels.

## Tables

Tables can be added in the following way, though alternatives are possible:

```markdown
Table: Note that table caption is automatically numbered and should be
given before the table itself.

| Header 1 | Header 2 |
| -------- | -------- |
| item 1 | item 2 |
| item 3 | item 4 |
```

This gives:

Table: Note that table caption is automatically numbered and should be
given before the table itself.

| Header 1 | Header 2 |
| -------- | -------- |
| item 1 | item 2 |
| item 3 | item 4 |

## Figures

A figure is added with:

```markdown
![Caption for BioHackrXiv logo figure](./biohackrxiv.png)
```

This gives:

![Caption for BioHackrXiv logo figure](./biohackrxiv.png)

Figures can be scaled by adding the width or height to the Markdown like this:

```markdown
![Caption for BioHackrXiv logo figure](./biohackrxiv.png){ width=50px }
```

# Other main section on your manuscript level 1

Lists can be added with:

1. Item 1
2. Item 2

# Citation Typing Ontology annotation

You can use [CiTO](http://purl.org/spar/cito/2018-02-12) annotations, as explained in [this BioHackathon Europe 2021 write up](https://raw.githubusercontent.com/biohackrxiv/bhxiv-metadata/main/doc/elixir_biohackathon2021/paper.md) and [this CiTO Pilot](https://www.biomedcentral.com/collections/cito).
Using this template, you can cite an article and indicate _why_ you cite that article, for instance DisGeNET-RDF [@citesAsAuthority:Queralt2016].

The syntax in Markdown is as follows: a single intention annotation looks like
`[@usesMethodIn:Krewinkel2017]`; two or more intentions are separated
with colons, like `[@extends:discusses:Nielsen2017Scholia]`. When you cite two
different articles, you use this syntax: `[@citesAsDataSource:Ammar2022ETL; @citesAsDataSource:Arend2022BioHackEU22]`.

Possible CiTO typing annotation include:

* citesAsDataSource: when you point the reader to a source of data which may explain a claim
* usesDataFrom: when you reuse somehow (and elaborate on) the data in the cited entity
* usesMethodIn
* citesAsAuthority
* citesAsEvidence
* citesAsPotentialSolution
* citesAsRecommendedReading
* citesAsRelated
* citesAsSourceDocument
* citesForInformation
* confirms
* documents
* providesDataFor
* obtainsSupportFrom
* discusses
* extends
* agreesWith
* disagreesWith
* updates
* citation: generic citation

# Results

## Towards tidyomics for AnnData objects
In this subproject, the aim was to begin extending tidyomics to AnnData objects. select() was chosen as the first tidyverse expression to implement. analyze_query_scope_select.AnnData() was created to analyze the scope of a select() operation based on the selected columns in AnnData objects, providing a foundation for the implementation of a select.AnnData() function. At present, it supports only obs, var, and layers, but it can be extended further. select.AnnData() will be the next function to be developed.

# Discussion

## Acknowledgements

Gemini CLI was used to summarise the results and outcomes in the preparation of this manuscript. Writing was reviewed by all authors before publication.

## References
