test_that("run_tf_integration sequencing data check", {

  data("test_results")
  mirna_exp_model <- run_edgeR_test2_input$mirna_exp_model
  tf_expression_model <- run_edgeR_test2_input$tf_expression_model
  interactions <- run_edgeR_test2_input$expanded_tf_mirna_couples
  interactions <- lapply(interactions, function(x) x[,1])


  myres <- suppressWarnings(.run_edgeR_integration(
                                  response_var = mirna_exp_model,
                                  interactions = interactions,
                                  covariates = tf_expression_model,
                                  norm_method = "TMM"))

  myres2 <- suppressWarnings(run_tf_integration(expression = mirna_exp_model,
                                tf_expression = tf_expression_model,
                                interactions = interactions,
                                sequencing_data = T,
                                norm_method = "TMM", normalize_cov = F))

  expect_identical(myres$model_results$`hsa-miR-29c-3p;iso_3p:a`,
                   myres2$model_results$`hsa-miR-29c-3p;iso_3p:a`)
  expect_identical(names(myres$model_results), names(myres2$model_results))
})


test_that("run_tf_integration microarray data check", {

  data("test_results")
  mirna_exp_model <- run_edgeR_test2_input$mirna_exp_model
  tf_expression_model <- run_edgeR_test2_input$tf_expression_model
  interactions <- run_edgeR_test2_input$expanded_tf_mirna_couples
  interactions <- lapply(interactions, function(x) x[,1])


  myres <- suppressWarnings(.run_lm_integration(response_var = mirna_exp_model,
                                 interactions = interactions,
                                 covariates = tf_expression_model))

  myres2 <- suppressWarnings(run_tf_integration(expression = mirna_exp_model,
                               tf_expression = tf_expression_model,
                               interactions = interactions,
                               sequencing_data = F, normalize_cov = F))


  expect_identical(myres$model_results[[5]]$coefficients,
                   myres2$model_results[[5]]$coefficients)

})
