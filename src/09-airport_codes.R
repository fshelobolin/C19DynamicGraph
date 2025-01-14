##################################################
## Project: C19 dynamic graph analysis
## Script purpose: parse airport code data
## Author: Filipp Shelobolin
##################################################

# Libraries ---------------------------------------------------------------

source("src/00-common.R")

# Load objects ------------------------------------------------------------

airport_codes <- readRDS(here::here("Rds", "airport_codes_raw.Rds"))

# Work --------------------------------------------------------------------
cat("Preparing airport codes..."); flush.console()
### AIRPORT CODES: converting them to FIPS (not currently used)
w_us_airports <- which(airport_codes$CountryCode == "US")
us_airports <- airport_codes[w_us_airports, ]
query_fips <- function(index) {
  ### The FCC has a free API for querying counties based on longitude & latitude.
  ### Function takes an iandex of airport_codes, returns FIPS of county.
  tbl_row <- us_airports[index, ]
  GET(
    "https://geo.fcc.gov/api/census/block/find",
    query = list(
      latitude = tbl_row$Lat,
      longitude = tbl_row$Lon
    )
  )$content %>%
    rawToChar() %>%
    read_html() %>%
    html_nodes("county") %>%
    html_attr("fips")
}
airport_codes <- airport_codes %>%
  dplyr::rename(
    airport_code = NodeName,
    country_code = CountryCode,
    sub_region_1 = StateCode
  ) %>%
  select(
    airport_code,
    country_code,
    sub_region_1
  )

w_not_us <- which(airport_codes$country_code != "US")
airport_codes$sub_region_1[w_not_us] <- NA ### For non-US, state doesn't matter.

save_object(airport_codes, "airport_codes")
cat("Done.\n"); flush.console()