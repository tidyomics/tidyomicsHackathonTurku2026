#' Analyze scope of a select operation based on selected columns for AnnData objects
#'
#' @keywords internal
#' @param se An AnnData object
#' @param columns_query Character vector of selected column names
#' @return List with scope ("obs_only", "var_only", "layers_only", "mixed", or "unknown") and details
#' @noRd

### analyze_query_scope_select.AnnData() analyses the scope of a select operation 
### based on selected columns for AnnData objects

### AnnData objects have more domains than SummerizeExperiments objects
### X        # main data matrix (w/o dimnames)
### layers   # alternative expression matrices
### obs      # observation annotation e. g. cell metadata
### var      # variable annotation e. g. feature metadata
### obsm     # cell embeddings, reduced dimensions
### varm     # feature embeddings
### uns      # unstructured metadata

### generate a column registry first 
### which provides information where a column name from a call to select() can be found within an AnnData object


### to start with, this only includes obs, var and layers
build_column_registry.AnnData <- function(ad) {
  
  dplyr::bind_rows(
    
    tibble::tibble(
      column = colnames(ad$obs),
      domain = "obs",
      source = "obs",
      key = paste0("obs:", colnames(ad$obs))
    ),
    
    tibble::tibble(
      column = colnames(ad$var),
      domain = "var",
      source = "var",
      key = paste0("var:", colnames(ad$var))
    ),
    
    if (length(ad$layers) > 0) {
    tibble::tibble(
      column = names(ad$layers),
      domain = "layers",
      source = "layers",
      key = paste0("layers:", names(ad$layers))
    )
    }
  )
}



analyze_query_scope_select.AnnData <- function(ad, ...) {
  
  ### generate column registry where column names can be found within an AnnData object
  registry <- build_column_registry.AnnData(ad)
  
  ### construct a zero-row tibble containing all selectable columns
  tbl <- tibble::as_tibble(
    stats::setNames(
      replicate(
        nrow(registry),
        logical(),
        simplify = FALSE
      ),
      registry$column
    )
  )
  
  ### resolve tidyselect expressions and provide row postions
  loc <- tidyselect::eval_select(
    rlang::expr(c(...)),
    tbl
  )
  
  selected_columns <- names(loc)
  
  ### look up selected columns in column registry
  selected_registry <-
    registry |>
    dplyr::filter(.data$column %in% selected_columns)
  
  ### detect ambiguity of selected column names
  ambiguous_columns <-
    selected_registry |>
    dplyr::count(.data$column) |>
    dplyr::filter(.data$n > 1)

  ### error message, if ambiguous columns were selected
  if (nrow(ambiguous_columns) > 0) {
    
    msg <-
      ambiguous_columns$column |>
      vapply(
        function(x) {
            ### domains of the ambigious columns
            domains <-
              selected_registry |>
              dplyr::filter(.data$column == x) |>
              dplyr::pull(.data$domain) |>
              unique()
          
            paste0(x, " [", paste(domains, collapse = ", "), "]")
        },
      character(1)
      )
    
    rlang::abort(
      paste(c("Ambiguous column selection detected.",
              "",
              "The following columns occur in multiple AnnData domains:",
          paste0("   ", msg)
        ),
        collapse = "\n"
      )
    )
  }
  
  
  ### determine domains of selected columns
  domains <- unique(selected_registry$domain)
  
  scope <-
    if (length(domains) == 0) {
      "unknown"
    } else if (length(domains) == 1) {
      paste0(domains, "_only")
    } else {
      "mixed"
    }
    
  
  list(
    scope = scope,
    
    domains = domains,
    
    targets_obs =
      "obs" %in% domains,
    targets_var =
      "var" %in% domains,
    targets_layers =
      "layer" %in% domains,
    
    selected_columns = selected_columns,
    selected_keys =
      selected_registry$key,
    selected_registry = selected_registry,
    
    selected_obs_cols =
      selected_registry |>
      dplyr::filter(.data$domain == "obs") |>
      dplyr::pull(.data$column),
    selected_var_cols =
      selected_registry |>
      dplyr::filter(.data$domain == "var") |>
      dplyr::pull(.data$column),
    selected_layer_cols =
      selected_registry |>
      dplyr::filter(.data$domain == "layer") |>
      dplyr::pull(.data$column),
   
     selected_obs_keys =
      selected_registry |>
      dplyr::filter(.data$domain == "obs") |>
      dplyr::pull(.data$key),
    selected_var_keys =
      selected_registry |>
      dplyr::filter(.data$domain == "var") |>
      dplyr::pull(.data$key),
    selected_layer_keys =
      selected_registry |>
      dplyr::filter(.data$domain == "layer") |>
      dplyr::pull(.data$key),
    
    analysis_method = "select_columns",
    
    confidence = "high"
  )
}
