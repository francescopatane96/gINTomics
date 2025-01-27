#' @import stringr
#' @importFrom stats residuals
.run_lm_integration <- function(response_var,
                               covariates,
                               interactions="auto",
                               steady_covariates=NULL,
                               reference=NULL,
                               normalize=T,
                               norm_method="TMM",
                               BPPARAM=BiocParallel::SerialParam()){

    tmp <- unlist(lapply(interactions, length))
    single_cov=F
    if(sum(tmp==1)==length(tmp)){
      single_cov=T
    }
  tmp <- .data_check(response_var = response_var,
                      interactions = interactions,
                      covariates = covariates)
    response_var <- tmp$response_var
    interactions <- tmp$interactions
    covariates <- tmp$covariates

    if(normalize==T) response_var <- .data_norm(response_var,
                                               method = norm_method)
    tmp <- .covariates_check(response_var = response_var,
                            covariates = covariates,
                            interactions = interactions,
                            steady_covariates = steady_covariates,
                            linear = T)
    covariates <- tmp$covariates
    response_var <- tmp$response_var
    interactions <- tmp$interactions
    steady_covariates <- tmp$steady_covariates
    original_id <- tmp$original_id
    fformula <- .generate_formula(interactions = interactions,
                                 linear=T)
    data <- cbind(response_var, covariates)
    lm_results <-  bplapply(fformula, .def_lm,
                            data=data,
                            BPPARAM = BPPARAM)
    names(lm_results) <- names(interactions)

    coef_pval_mat <- .building_result_matrices(model_results = lm_results,
                                              type = "lm",
                                              single_cov = single_cov)
    tmp <- lapply(lm_results, function(x) as.data.frame(t(residuals(x))))
    rresiduals <- rbind.fill(tmp)
    colnames(rresiduals) <- rownames(response_var)
    rownames(rresiduals) <- names(tmp)


    results <- list(
      model_results = lm_results,
      coef_data = coef_pval_mat$coef,
      pval_data = coef_pval_mat$pval,
      residuals = rresiduals,
      data = list(response_var = response_var,
                  covariates = covariates,
                  formula = fformula))
    if(nrow(original_id)>0){
      results <- .id_conversion(dictionary = original_id,
                               results = results)
    }
    return(results)
}


##################################
#' @importFrom stats lm

.def_lm <- function(formula,
                    data){

  if(length(attr(terms(formula), "term.labels"))>
     as.integer(nrow(data)*0.4)){

    tmp <- as.character(formula[2])
    tmp2 <- .rf_selection(formula = formula,
                          data = data)
    formula <- as.formula(paste(tmp, "~", as.character(tmp2[2])))
  }

  lm_results <- summary(lm(formula, data = data))
  return(lm_results)
}

