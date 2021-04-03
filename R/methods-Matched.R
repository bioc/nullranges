## Define accessor functions for Matched class -------------------------------------------

#' Accessor methods for Matched Class
#'
#' @description 
#' Functions that get data from Matched subclasses
#' such as Matched, MatchedDataFrame, MatchedGRanges,
#' and MatchedGInteractions. 
#'
#' @param x Matched object
#' @param ... additional arguments
#'
#' @rdname Matched
#' @export
setMethod("matchedData", "Matched", function(x, ...) {
  x@matchedData
})

#' @rdname Matched
#' @export
setMethod("covariates", "Matched", function(x, ...) {
  x@covar
})

getIndices <- function(x, group = 'matched') {
  ## Get group argument
  group <- match.arg(group, choices=c("focal","matched", "pool", "unmatched"))
  
  ## Get the length of each focal and pool
  n.focal <- nrow(x@matchedData[group == 'focal'])
  n.pool  <- nrow(x@matchedData[group == 'pool'])
  
  if (group == 'focal')
    return(1:n.focal)
  
  if (group == 'matched')
    return(x@matchedIndex)
  
  if (group == 'unmatched')
    return(which(!(1:n.pool) %in% x@matchedIndex))
  
  if (group == 'pool')
    return(1:n.pool)
}

#' @param group a character string describing from which group to extract indices.
#'              can be one of 'focal', 'matched', 'pool', or 'unmatched'.
#' @rdname Matched
#' @export
setMethod("indices", "Matched", getIndices)


## Define overview method for Matched class ----------------------------------------------

overviewMatched <- function(x) {
  
  ## Define aggregation function
  agg <- function(x) {
    list(mean = mean(x), sd = sd(x))
  }
  
  ## Apply aggregation to matchedData
  md.agg <- x@matchedData[, as.list(c(N =.N, unlist(lapply(.SD, agg)))),
                          .SDcols = -c('id'), by = group]
  
  ## Calculate distances between focal and matched
  d <- x@matchedData[group == 'focal', -c('id', 'group')] -
    x@matchedData[group == 'matched', -c('id', 'group')]
  
  ## Apply aggregation to distances
  d.agg <- d[, as.list(unlist(lapply(.SD, agg)))]
  
  ## Display overview
  cat(class(x), "object:", '\n', sep = ' ')
  print(md.agg, row.names = F)
  cat('--------\n')
  cat('focal - matched: \n')
  print(d.agg, row.names = F)
  
}

#' @rdname Matched
#' @export
setMethod("overview", signature(x="Matched"), overviewMatched)


## Define plot methods for Matched class -------------------------------------------------

## Define function for plotting propensity scores
plotPropensity <- function(x, type, log) {
  
  ## Extract matchedData
  md <- matchedData(x)
  
  ## Reverse level order
  md$group <- factor(x = md$group,
                     levels = rev(c('focal', 'matched', 'pool', 'unmatched')))
  
  ## Define jitter and ridge type plots
  jitter <- ggplot(data = md, aes(x = ps, y = group, color = group)) +
    geom_jitter(height = 0.25, width = 0) +
    labs(x = "Propensity Score", y = "")+
    theme_minimal()+
    theme(legend.position = 'none')
  
  ridge  <- ggplot(dat = md, aes(x = ps, y = group, fill = group))+
    geom_density_ridges(alpha = 0.7)+
    labs(x = "Propensity Score", y = "")+
    theme_minimal()+
    theme(legend.position = 'none')
  
  if (!missing(log)) {
    if (log) {
      
      jitter <- ggplot(data = md, aes(x = log(ps), y = group, color = group)) +
        geom_jitter(height = 0.25, width = 0) +
        labs(x = "Propensity Score", y = "")+
        theme_minimal()+
        theme(legend.position = 'none')
      
      ridge  <- ggplot(dat = md, aes(x = log(ps), y = group, fill = group))+
        geom_density_ridges(alpha = 0.7)+
        labs(x = "Propensity Score", y = "")+
        theme_minimal()+
        theme(legend.position = 'none')
      
    }
  }
  
  if (missing(type)) {
    
    ## Chose plot type by data size
    if (nrow(md[group == "pool"]) <= 10000)
      return(jitter)
    else
      return(ridge)
    
  } else {
    
    ## Parse type argument
    type <- match.arg(type, choices = c('jitter', 'ridge'))
    
    ## Choose plot type by argument
    if (type == 'jitter')
      return(jitter)
    if (type == 'ridge')
      return(ridge)
    
  }
  
}

## Define function for plotting covariates
plotCovariates <- function(x, covar, type, log) {
  
  ## Extract matchedData
  md <- matchedData(x)
  
  ## Reverse level order
  md$group <- factor(x = md$group,
                     levels = rev(c('focal', 'matched', 'pool', 'unmatched')))
  
  ## Parse covariate to plot
  covar <- match.arg(covar, choices = c('all', covariates(x)), several.ok = T)
  
  if (length(covar) == 1) {
    if (covar == 'all') {
      covar <- covariates(x)
    }
  }
  
  ## Melt data for plotting multiple covariates
  mmd <- melt(md, measure.vars = covar)
  
  ## Define jitter and ridge type plots
  jitter <- ggplot(data = mmd, aes(x = value, y = group, color = group)) +
    facet_grid(~variable, scales = "free_x") +
    geom_jitter(height = 0.25, width = 0) +
    labs(y = "")+
    theme_minimal()+
    theme(legend.position = 'none')
  
  ridge  <- ggplot(dat = mmd, aes(x = value, y = group, fill = group))+
    facet_grid(~variable, scales = "free_x") +
    geom_density_ridges(alpha = 0.7)+
    labs(y = "")+
    theme_minimal()+
    theme(legend.position = 'none')
  
  if (!missing(log)) {
    if (log) {
      
      jitter <- ggplot(data = mmd, aes(x = log(value), y = group, color = group)) +
        facet_grid(~variable, scales = "free_x") +
        geom_jitter(height = 0.25, width = 0) +
        labs(y = "")+
        theme_minimal()+
        theme(legend.position = 'none')
      
      ridge  <- ggplot(dat = mmd, aes(x = log(value), y = group, fill = group))+
        facet_grid(~variable, scales = "free_x") +
        geom_density_ridges(alpha = 0.7)+
        labs(y = "")+
        theme_minimal()+
        theme(legend.position = 'none')
    }
  }
  
  if (missing(type)) {
    
    ## Chose plot type by data size
    if (nrow(md[group == "pool"]) <= 10000)
      return(jitter)
    else
      return(ridge)
    
  } else {
    
    ## Parse type argument
    type <- match.arg(type, choices = c('jitter', 'ridge'))
    
    ## Choose plot type by argument
    if (type == 'jitter')
      return(jitter)
    if (type == 'ridge')
      return(ridge)
    
  }
}

#' @rdname Matched
#' @import ggplot2 ggridges
#' @export
setMethod("plot", signature(x="Matched"), plotPropensity)

#' @rdname Matched
#' @import ggplot2 ggridges
#' @export
setMethod("plot", signature(x="Matched", covar = 'character'), plotCovariates)