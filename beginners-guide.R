## Tidyomics Beginner's Guide -- May 2026
## Examples from https://github.com/tidyomics using real Bioconductor datasets
## See the tidyomics page for links to package vignettes and more tutorials

# Install tidyomics suite if needed:
# BiocManager::install("tidyomics")

# ============================================================
# 1. tidySummarizedExperiment — bulk RNA-seq (airway)
#    Comparison: tidy API vs. base R
# ============================================================

library(airway)
library(tidySummarizedExperiment)

data(airway)
airway

library(tidyprint)
airway |> print()

# Tidy approach: mean counts per gene across treated samples
airway |>
  filter(dex == "trt") |>
  group_by(gene_id) |>
  summarize(mean_count = mean(counts))

# Equivalent base R
treated <- airway[, airway$dex == "trt"]
data.frame(
  gene_id    = rownames(treated),
  mean_count = rowMeans(assay(treated, "counts"))
) |>
  head()

# Now just some basic demos of the capabilities of tidySummarizedExperiment:

# Derive a new colData column from existing metadata
airway |>
  mutate(treated = ifelse(dex == "trt", "yes", "no")) |>
  colData()

# Violin plot of log-expression for the first 1000 genes
subset_symb <- head(rowData(airway)$symbol, 1000)
airway |>
  mutate(log_counts = log10(counts + 1)) |>
  filter(symbol %in% subset_symb) |>
  ggplot(aes(dex, log_counts, fill = dex, group = .sample)) +
  geom_violin() +
  theme_bw()

# ============================================================
# 2. tidybulk — differential expression (airway)
# ============================================================

library(tidybulk)
library(ggplot2)
library(ggrepel)

filt <- airway |>
  identify_abundant(formula_design = ~dex) |>
  scale_abundance(method = "RLE")

de_airway <- filt |>
  test_differential_abundance(method = "DESeq2", .formula = ~cell + dex)

de_airway |>
  filter(padj < .01) |>
  ggplot(aes(log2FoldChange, -log10(padj))) +
  geom_point() +
  theme_bw() + 
  coord_cartesian(xlim=c(-4,4),ylim=c(0,30))

# PCA to visualise sample separation by treatment
filt |>
  reduce_dimensions(method = "PCA") |>
  pivot_sample() |>
  ggplot(aes(PC1, PC2, color = dex, label = .sample)) +
  geom_point(size = 3) +
  geom_text_repel() +
  theme_bw()

# ============================================================
# 3. plyranges — ATAC-seq peaks overlapping promoters
#    Data: fluentGenomics workflow package
# ============================================================

library(plyranges)
library(fluentGenomics) # for the peaks
library(TxDb.Hsapiens.UCSC.hg38.knownGene) # for the genes
library(GenomeInfoDb) # for the genome

# ATAC-seq peaks, see fluentGenomics workflow for details
data(peaks)
peaks

# Build promoter windows from UCSC knownGene (GRCh38), standard chromosomes only
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
g <- genes(txdb) |>
  keepStandardChromosomes(pruning.mode = "coarse")

promoters_gr <- g |> promoters(upstream = 2000, downstream = 0)

# We could also perform this via plyranges
promoters_gr2 <- g |> 
  anchor_5p() |>
  mutate(width=1) |>
  flank_upstream(width=2000) 

all.equal(promoters_gr, promoters_gr2)

library(DFplyr) # for operating on the DataFrame at the end

# Tidy plyranges: count ATAC peaks per gene promoter:
# the flexibility here is that any statistic on the columns could be summarized
peaks |>
  join_overlap_inner(promoters_gr) |>
  group_by(gene_id) |>
  summarize(n_peaks = n()) |>
  pull(n_peaks) |>
  table()

# Alternative: count_overlaps() annotates each promoter directly.
# (magrittr pipe `%>%` is needed in the first line 
# for the embedded placeholder `.` on the right side)
library(magrittr)
promoters_gr %>%
  mutate(n_peaks = count_overlaps(., peaks)) |>
  filter(n_peaks > 0) |>
  pull(n_peaks) |>
  table()
