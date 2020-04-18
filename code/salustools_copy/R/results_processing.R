#' Process Raw SALUS Output
#'
#' This function takes the output daily files and converts daily sums to
#' annual values. Requires dplyr.
#'
#' @param scratchDir Raw SALUS output directory
#' @param outDir directory to export cleaned/summarized output
#' @param runname Run name
#' @param startYear First year of harvest
#' @keywords results raw
#' @export
#' @examples
#' # test
#' runResults <- salusRawToAnnual(scratchDir, outDir, runname, startYear)



# define function
salusRawToAnnual <- function(scratchDir, outDir, runname, startYear){
  library(dplyr)
  library(readr)

  # load daily results within scratchDir
  dailyFiles <- list.files(scratchDir, pattern = '*daily.csv')

  # load daily files, get annual non-cumulative totals, and combine into 1 df
  annualResults <- do.call(rbind, lapply(dailyFiles, function(x){
    # load file
    ddf <- read_csv(paste0(scratchDir, '/', x))

    # make an annual crop table - speciesID where GWAD is max
    cropByYear <- ddf %>%
      group_by(ExpID,Year) %>%
      slice(which.max(GWAD)) %>%
      dplyr::select(c(ExpID,Year, SpeciesID))

    # get maximum values per year
    adf <- ddf %>%
      group_by(ExpID, Year) %>%
      summarize(GWAD = max(GWAD, na.rm=TRUE),
                IRRC_cum = max(IRRC, na.rm=TRUE),
                DRNC_cum = max(DRNC, na.rm=TRUE),
                PREC_cum = max(PREC, na.rm = TRUE),
                ETAC_cum = max(ETAC, na.rm=TRUE),
                ESAC_cum = max(ESAC, na.rm=TRUE),
                EPAC_cum = max(EPAC, na.rm=TRUE),
                ROFC_cum = max(ROFC, na.rm=TRUE)) %>%
      # add species name back in
      left_join(cropByYear, by = c('ExpID','Year')) %>%
      # de-cumulate irrc, drnc, prec (turn to annual values)
      mutate(IRRC_mm = IRRC_cum - lag(IRRC_cum, default=0),
             DRNC_mm = DRNC_cum - lag(DRNC_cum, default=0),
             PREC_mm = PREC_cum - lag(PREC_cum, default=0),
             ETAC_mm = ETAC_cum -lag(ETAC_cum, default = 0),
             ESAC_mm = ESAC_cum -lag(ESAC_cum, default = 0),
             EPAC_mm = EPAC_cum -lag(EPAC_cum, default = 0),
             ROFC_mm = ROFC_cum -lag(ROFC_cum, default = 0)) %>%
      dplyr::select(c(ExpID, Year, SpeciesID, GWAD, IRRC_mm, DRNC_mm, PREC_mm,
                      ETAC_mm, ESAC_mm, EPAC_mm, ROFC_mm)) %>%
      filter(Year >= startYear)

    # add an irrigation flag
    adf$irrigation <- 'N'
    adf[adf$IRRC_mm > 0 ,'irrigation'] <- 'Y'

    return(adf)
  }))

  # write out
  write_csv(annualResults, path = paste0(outDir, '/', runname, '.csv'))
  return(annualResults)
}
