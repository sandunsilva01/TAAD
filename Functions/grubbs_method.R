#####################Grubb's Test####################################################

options(width=250)


grubbs.method <- function(x, Grubbs.sig) {
  outliers <- NULL
  outlier.loc <- NULL
  pv.out <- NULL
  test <- x
  grubbs.result <- grubbs.test(test)
  pval <- grubbs.result$p.value
  
  if (length(test) < 3 ) stop("Grubb's test requires more than two sample values")
  while(pval < Grubbs.sig) {
    outlier <- as.numeric(strsplit(grubbs.result$alternative," ")[[1]][3])
    outliers <- c(outliers, outlier )
    outlier.loc <- c(outlier.loc, which(x %in% outlier==T)  )
    pv.out <- c(pv.out, grubbs.result$p.value)
    test <- x[!x %in% outliers]
    
    if (length(test) < 3 ) {
      warning("All but two values flagged as outliers")
      break
    }
    grubbs.result <- grubbs.test(test)
    pval <- grubbs.result$p.value
  }
  return( list(outlier = outliers, Outlier.loci = outlier.loc, Pval = pv.out))
}
