###############################################################################
# REVISED ABN SCRIPT
# 2016 baseline / diet exposure / frailty mediator
# GSEM is not modified here; this script only updates the ABN stage.
###############################################################################

rm(list = ls())

suppressPackageStartupMessages({
  library(abn)
  library(haven)
  library(Rgraphviz)
  library(graph)
  library(grid)
  library(grDevices)
})

make_numeric <- function(x, varname = NULL) {
  out <- suppressWarnings(as.numeric(as.character(x)))
  if (all(is.na(out)) && any(!is.na(x))) stop("Could not convert ", varname, " to numeric.")
  out
}

make_bin_factor <- function(x, varname) {
  x_chr <- as.character(x)
  x_chr[x_chr %in% c("", "NA", "<NA>")] <- NA
  ux <- sort(unique(x_chr[!is.na(x_chr)]))
  if (length(ux) != 2) {
    stop("Variable ", varname, " assigned as binomial but has ", length(ux), " unique non-missing values.")
  }
  factor(x_chr, levels = ux)
}

extract_dag_matrix <- function(x) {
  if (is.matrix(x)) return(x)
  recurse_find_matrix <- function(obj) {
    if (is.matrix(obj)) return(obj)
    if (is.list(obj)) {
      for (i in seq_along(obj)) {
        ans <- recurse_find_matrix(obj[[i]])
        if (!is.null(ans)) return(ans)
      }
    }
    NULL
  }
  ans <- recurse_find_matrix(x)
  if (!is.null(ans)) return(ans)
  stop("Could not extract a DAG matrix from the ABN object.")
}

sanitize_dag_matrix <- function(m, target_names) {
  m <- as.matrix(m)
  if (is.null(rownames(m)) && !is.null(colnames(m))) rownames(m) <- colnames(m)
  if (is.null(colnames(m)) && !is.null(rownames(m))) colnames(m) <- rownames(m)
  m <- m[target_names, target_names, drop = FALSE]
  storage.mode(m) <- "numeric"
  m[m != 0] <- 1
  diag(m) <- 0
  m
}

get_abn_dag <- function(learned_obj, node_names) {
  sanitize_dag_matrix(extract_dag_matrix(learned_obj), node_names)
}

make_arc_df <- function(amat_abn) {
  arc_idx <- which(amat_abn == 1, arr.ind = TRUE)
  if (length(arc_idx) == 0 || nrow(arc_idx) == 0) {
    return(data.frame(from = character(0), to = character(0), stringsAsFactors = FALSE))
  }
  data.frame(
    from = colnames(amat_abn)[arc_idx[, 2]],
    to   = rownames(amat_abn)[arc_idx[, 1]],
    stringsAsFactors = FALSE
  )
}

make_graphNEL_from_abn <- function(amat_abn) {
  node_names <- rownames(amat_abn)
  gNEL <- new("graphNEL", nodes = node_names, edgemode = "directed")
  arc_df <- make_arc_df(amat_abn)
  if (nrow(arc_df) > 0) {
    for (i in seq_len(nrow(arc_df))) gNEL <- addEdge(arc_df$from[i], arc_df$to[i], gNEL, 1)
  }
  gNEL
}

plot_rgraphviz_abn <- function(amat_abn, dist.list, file, main_title = NULL) {
  gNEL <- make_graphNEL_from_abn(amat_abn)
  node_names <- nodes(gNEL)
  shape_vec <- sapply(node_names, function(v) if (dist.list[[v]] == "binomial") "box" else "ellipse", USE.NAMES = TRUE)
  attrs <- list(graph = list(rankdir = "LR", fontsize = 20), node = list(fixedsize = FALSE), edge = list(arrowsize = 1.0))
  nAttrs <- list(shape = as.list(shape_vec), fillcolor = as.list(setNames(rep("white", length(node_names)), node_names)))
  pdf(file, width = 18, height = 12)
  renderGraph(layoutGraph(gNEL, attrs = attrs, nodeAttrs = nAttrs))
  if (!is.null(main_title)) grid.text(main_title, y = unit(0.98, "npc"), gp = gpar(fontsize = 18))
  dev.off()
}

check_parent_limit_plus2 <- function(amat_abn, default_max, outcome_node = "d_outcome") {
  n_parents <- rowSums(amat_abn)
  allowed <- setNames(rep(default_max, length(n_parents)), names(n_parents))
  if (outcome_node %in% names(allowed)) allowed[outcome_node] <- default_max + 2
  list(n_parents = n_parents, allowed = allowed, max_found = max(n_parents), bad_nodes = names(n_parents)[n_parents > allowed[names(n_parents)]])
}

run_abn_analysis <- function(data_file, out_dir, suffix) {
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

  dat <- read_dta(data_file)
  dat <- as.data.frame(dat)

  vars_use <- c(
    "d_outcome", "t1", "t2", "t3",
    "AGE_pm", "SEX", "NHB", "HISP", "OTHER",
    "zses_2016_pm", "married_2016_pm",
    "smoking_2016_pm", "alcohol_2016_pm", "physic_act_2016_pm",
    "bmibr_2016_pm", "hbp_ever_2016", "diab_ever_2016", "heart_ever_2016", "stroke_ever_2016", "srh_2016_pm",
    "diet3_2016", "frailty3_2016"
  )

  missing_vars <- setdiff(vars_use, names(dat))
  if (length(missing_vars) > 0) stop("Missing variables: ", paste(missing_vars, collapse = ", "))

  dat2 <- dat[, vars_use, drop = FALSE]

  factor_vars <- c("d_outcome", "t1", "t2", "t3", "SEX", "NHB", "HISP", "OTHER", "married_2016_pm", "hbp_ever_2016", "diab_ever_2016", "heart_ever_2016", "stroke_ever_2016", "srh_2016_pm")
  numeric_vars <- c("AGE_pm", "zses_2016_pm", "smoking_2016_pm", "alcohol_2016_pm", "physic_act_2016_pm", "bmibr_2016_pm", "diet3_2016", "frailty3_2016")

  for (v in factor_vars) dat2[[v]] <- make_bin_factor(dat2[[v]], v)
  for (v in numeric_vars) dat2[[v]] <- make_numeric(dat2[[v]], v)

  dat2 <- dat2[complete.cases(dat2), , drop = FALSE]
  if (nrow(dat2) == 0) stop("No complete cases remain.")

  abndata <- as.data.frame(dat2)

  data.dists <- list(
    d_outcome        = "binomial",
    t1               = "binomial",
    t2               = "binomial",
    t3               = "binomial",
    AGE_pm           = "gaussian",
    SEX              = "binomial",
    NHB              = "binomial",
    HISP             = "binomial",
    OTHER            = "binomial",
    zses_2016_pm     = "gaussian",
    married_2016_pm  = "binomial",
    smoking_2016_pm  = "gaussian",
    alcohol_2016_pm  = "gaussian",
    physic_act_2016_pm = "gaussian",
    bmibr_2016_pm    = "gaussian",
    hbp_ever_2016    = "binomial",
    diab_ever_2016   = "binomial",
    heart_ever_2016  = "binomial",
    stroke_ever_2016 = "binomial",
    srh_2016_pm      = "binomial",
    diet3_2016       = "gaussian",
    frailty3_2016    = "gaussian"
  )

  banned <- matrix(0, nrow = ncol(abndata), ncol = ncol(abndata))
  rownames(banned) <- colnames(banned) <- names(abndata)

  demo_vars      <- c("AGE_pm", "SEX", "NHB", "HISP", "OTHER")
  ses_vars       <- c("zses_2016_pm")
  marital_vars   <- c("married_2016_pm")
  lifestyle_vars <- c("smoking_2016_pm", "alcohol_2016_pm", "physic_act_2016_pm")
  health_vars    <- c("bmibr_2016_pm", "hbp_ever_2016", "diab_ever_2016", "heart_ever_2016", "stroke_ever_2016", "srh_2016_pm")
  exposure_vars  <- c("diet3_2016")
  mediator_vars  <- c("frailty3_2016")
  time_vars      <- c("t1", "t2", "t3")
  outcome_vars   <- c("d_outcome")
  all_vars       <- names(abndata)

  banned[setdiff(all_vars, "d_outcome"), "d_outcome"] <- 1
  banned[demo_vars, setdiff(all_vars, demo_vars)] <- 1

  for (v in ses_vars) banned[v, c(demo_vars, ses_vars)] <- 1
  for (v in marital_vars) banned[v, c(demo_vars, ses_vars, marital_vars)] <- 1
  for (v in lifestyle_vars) banned[v, c(demo_vars, ses_vars, marital_vars, lifestyle_vars)] <- 1
  for (v in health_vars) banned[v, c(demo_vars, ses_vars, marital_vars, lifestyle_vars, health_vars)] <- 1
  for (v in exposure_vars) banned[v, c(demo_vars, ses_vars, marital_vars, lifestyle_vars, health_vars, exposure_vars, mediator_vars, time_vars, outcome_vars)] <- 1
  for (v in mediator_vars) banned[v, c(demo_vars, ses_vars, marital_vars, lifestyle_vars, health_vars, mediator_vars, time_vars, outcome_vars)] <- 1
  for (tv in time_vars) banned[tv, setdiff(all_vars, c(demo_vars, ses_vars, marital_vars, tv))] <- 1

  write.csv(banned, file = file.path(out_dir, paste0("ABN_banned_matrix_", suffix, ".csv")))

  score.summary <- data.frame()
  dag.list <- list()
  for (mp in 1:4) {
    outcome_parent_cap <- mp + 2
    max.parents.use <- setNames(rep(mp, ncol(abndata)), names(abndata))
    max.parents.use["d_outcome"] <- outcome_parent_cap

    mycache <- buildScoreCache(
      data.df      = abndata,
      data.dists   = data.dists,
      dag.banned   = banned,
      max.parents  = max.parents.use,
      method       = "bayes"
    )

    mydag <- searchHillClimber(score.cache = mycache)
    fabn  <- fitAbn(object = mydag, method = "bayes")
    dag_mat <- get_abn_dag(mydag, colnames(abndata))
    dag.list[[paste0("mp", mp)]] <- dag_mat

    parent_check <- check_parent_limit_plus2(dag_mat, mp, "d_outcome")
    score.summary <- rbind(score.summary, data.frame(max_parents_non_outcome = mp, mlik = if (!is.null(fabn$mlik)) as.numeric(fabn$mlik) else NA_real_, max_found = parent_check$max_found, stringsAsFactors = FALSE))

    write.csv(make_arc_df(dag_mat), file = file.path(out_dir, paste0("ABN_arcs_", suffix, "_mp", mp, ".csv")), row.names = FALSE)
    plot_rgraphviz_abn(dag_mat, data.dists, file.path(out_dir, paste0("ABN_plot_", suffix, "_mp", mp, ".pdf")), main_title = paste("ABN", suffix, "mp", mp))
  }

  write.csv(score.summary, file = file.path(out_dir, paste0("ABN_score_summary_", suffix, ".csv")), row.names = FALSE)
  best.idx <- if (all(is.na(score.summary$mlik))) 1 else which.max(score.summary$mlik)
  best.mp <- score.summary$max_parents_non_outcome[best.idx]
  write.csv(make_arc_df(dag.list[[paste0("mp", best.mp)]]), file = file.path(out_dir, paste0("ABN_best_arcs_", suffix, "_mp", best.mp, ".csv")), row.names = FALSE)
  invisible(list(score.summary = score.summary, best.mp = best.mp, best.amat = dag.list[[paste0("mp", best.mp)]]))
}

out_dir_main <- "E:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DEPRESSIVESYMPTOMS_NEUROPATHOLOGICALMARKERS_DEMENTIA/OUTPUT"

res_DEMMCI <- run_abn_analysis(
  data_file = "E:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DEPRESSIVESYMPTOMS_NEUROPATHOLOGICALMARKERS_DEMENTIA/FINAL_DATA/HRS_ABN_MCIDEM_READY_2016_DIETFRAILTY.dta",
  out_dir   = out_dir_main,
  suffix    = "DEMMCI_2016_DIETFRAILTY"
)

res_MCI <- run_abn_analysis(
  data_file = "E:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DEPRESSIVESYMPTOMS_NEUROPATHOLOGICALMARKERS_DEMENTIA/FINAL_DATA/HRS_ABN_MCI_READY_2016_DIETFRAILTY.dta",
  out_dir   = out_dir_main,
  suffix    = "MCI_2016_DIETFRAILTY"
)

res_DEM <- run_abn_analysis(
  data_file = "E:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DEPRESSIVESYMPTOMS_NEUROPATHOLOGICALMARKERS_DEMENTIA/FINAL_DATA/HRS_ABN_DEM_READY_2016_DIETFRAILTY.dta",
  out_dir   = out_dir_main,
  suffix    = "DEM_2016_DIETFRAILTY"
)
