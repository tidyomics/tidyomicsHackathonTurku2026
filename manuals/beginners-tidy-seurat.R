## Tidyomics Beginner's Guide — tidyseurat -- May 2026
## Single-cell RNA-seq: tidy interface over Seurat objects
## Data: pbmc_small (bundled with Seurat) — 80 PBMCs, two sample groups

# Install if needed:
# BiocManager::install("tidyseurat")
# install.packages(c("Seurat", "ggplot2"))

# ============================================================
# 0. Load the built-in demo dataset
# ============================================================

library(Seurat)
library(tidyseurat)
library(ggplot2)

# pbmc_small ships with Seurat: 80 cells, 230 genes, two sample groups (g1/g2)
data("pbmc_small")
seurat_obj <- pbmc_small

# ============================================================
# 1. Tidy inspection
# ============================================================

# tidyseurat: Seurat objects print and behave like tibbles
seurat_obj

# Select metadata columns of interest
seurat_obj |>
  select(.cell, groups, letter.idents, nCount_RNA, nFeature_RNA)

# Filter to one group
seurat_obj |> filter(groups == "g2")

# Count cells per group and cluster
seurat_obj |>
  group_by(groups, letter.idents) |>
  summarize(n_cells = n())

# ============================================================
# 2. QC and filtering
# ============================================================

# Metadata columns work directly in aes() — no extra extraction needed
seurat_obj |>
  ggplot(aes(nCount_RNA, nFeature_RNA, color = letter.idents)) +
  geom_point(alpha = 0.7) +
  facet_wrap(~groups) +
  scale_x_log10() + scale_y_log10() +
  theme_bw()

# Adjust thresholds after inspecting the QC plots above
seurat_filtered <- seurat_obj |>
  filter(nFeature_RNA > 50, nCount_RNA > 100)

# ============================================================
# 3. Normalisation, variable features, and scaling
# ============================================================

# Standard Seurat pipeline — pipes work because each function returns
# the modified Seurat object
seurat_filtered <- seurat_filtered |>
  NormalizeData() |>
  FindVariableFeatures(nfeatures = 100) |>
  ScaleData()

# ============================================================
# 4. Dimensionality reduction and clustering
# ============================================================

seurat_filtered <- seurat_filtered |>
  RunPCA(npcs = 10) |>
  FindNeighbors(dims = 1:5) |>
  FindClusters(resolution = 0.4) |>
  RunUMAP(dims = 1:5)

# ============================================================
# 5. Tidy exploration of clustering results
# ============================================================

# group_by + summarize: cluster composition by group
seurat_filtered |>
  group_by(seurat_clusters, groups) |>
  summarize(
    n_cells     = n(),
    mean_counts = mean(nCount_RNA)
  )

# Tidy ggplot2: tidyseurat exposes umap_1, umap_2 directly in aes()
seurat_filtered |>
  ggplot(aes(umap_1, umap_2, color = groups)) +
  geom_point(size = 1.5, alpha = 0.7) +
  theme_bw()

# Equivalent base Seurat
DimPlot(seurat_filtered, reduction = "umap", group.by = "groups")

# ============================================================
# 6. Join gene expression into the tidy frame
# ============================================================

# join_features() adds normalised expression columns for selected genes
top2 <- VariableFeatures(seurat_filtered)[1:2]

seurat_with_exprs <- seurat_filtered |>
  join_features(features = top2, shape = "long") |>
  mutate(.feature = factor(.feature, levels = top2)) 

# we drop the first two colors in the Blues palette (too light)
seurat_with_exprs |>
  ggplot(aes(umap_1, umap_2, color = .abundance_RNA)) +
  geom_point(size = 2, alpha = 0.8) +
  scale_color_gradientn(colors = RColorBrewer::brewer.pal(9, "Blues")[3:9]) +
  facet_wrap(~.feature) +
  theme_bw() +
  theme(panel.grid = element_blank())

# Equivalent base Seurat
FeaturePlot(seurat_filtered, features = top2)
