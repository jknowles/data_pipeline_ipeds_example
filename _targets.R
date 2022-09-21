library(targets)
library(tarchetypes)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write
source("R/functions.R")

# Set target-specific options such as packages.
tar_option_set(packages = c("dplyr", "fs", "readxl", "openxlsx"))



download_and_unzip <- function(url) {

  download_file <- function(url, dest) {
    download.file(url, dest)
    dest
  }

  downloaded_zip <- tempfile()
  download_file(url, downloaded_zip)
  unzip(downloaded_zip, exdir = dir_create("data"))
}

# End this file with a list of target objects.
list(
  tar_target(hd21_url,
             "https://nces.ed.gov/ipeds/datacenter/data/HD2021.zip",
             format = "url"),
  tar_target(hd_files,
             download_and_unzip(hd21_url),
             format = "file"
             ),
  tar_target(effy2021_url,
             "https://nces.ed.gov/ipeds/datacenter/data/EFFY2021.zip",
             format = "url"
             ),
  tar_target(effy2021_files,
             download_and_unzip(effy2021_url),
             format = "file"
             ),
  tar_target(college_scorecard_url,
             "https://ed-public-download.app.cloud.gov/downloads/Most-Recent-Cohorts-Institution_04262022.zip",
             format = "url"),
  tar_target(dict_cs_url,
             "https://collegescorecard.ed.gov/assets/CollegeScorecardDataDictionary.xlsx",
             format = "url"
  ),
  tar_target(dict_cs,
             openxlsx::read.xlsx(dict_cs_url, sheet = "Institution_Data_Dictionary"),
  ),
  tar_target(college_scorecard_files,
             download_and_unzip(college_scorecard_url),
             format = "file"
             ),
  tar_target(cs_data,
             read.csv(college_scorecard_files)),
  tar_target(dict_hd21_url,
             "https://nces.ed.gov/ipeds/datacenter/data/HD2021_Dict.zip",
             format = "url"),
  tar_target(dict_effy2021_url,
             "https://nces.ed.gov/ipeds/datacenter/data/EFFY2021_Dict.zip",
             format = "url"),
  tar_target(hd_dict_file,
             download_and_unzip(dict_hd21_url),
             format = "file"
  ),
  tar_target(hd_dict, readxl::read_excel(hd_dict_file, sheet = "varlist")),
  tar_target(effy_dict_file,
             download_and_unzip(dict_effy2021_url),
             format = "file"
  ),
  tar_target(effy_dict, readxl::read_excel(effy_dict_file, sheet = "varlist")),

  # https://stackoverflow.com/questions/70281450/dealing-with-zip-files-in-a-targets-workflow
  #tar_target(file_names, hd_files), # if there are multiple files?
  tar_target(ipeds_enroll, read.csv(effy2021_files)),
  tar_target(ipeds_inst_char, read.csv(hd_files)),


  # Left join inst_char onto enroll
  # Left join above onto CS

  tar_target(combine_data,
             {
               tmp <- left_join(prune_ipeds_inst_char(ipeds_inst_char),
                                prune_ipeds_enroll(ipeds_enroll), by = "UNITID")
               tmp <- left_join(tmp,
                                prune_cs(cs_data), by = "UNITID")
               tmp
             }
             ),

  # Make a report by a cut of the data with 5-7 levels, parameterize the report
  # Make an overall report
  # Fin

  #tar_group_by(sector_grouped, combine_data, C21BASIC),
  #tar_target(pars, ),
  #tar_target(sector_report_source, "sector_report.Rmd", format = "file"),
  tar_render_rep(sector_report,
             path = "sector_report.Rmd",
             params =
               data.frame(sector_flag = c(15, 16, 17, 18, 19, 20, 21, 22),
                                 output_file = paste0("reports/",
                                                      c("sector_r1", "sector_r2",
                                                        "sector_doctoral", "sector_largerMA", "sector_mediumMA",
                                                        "sector_smallMA", "sector_ba_arts", "sector_ba_diverse")))
             ),

  #   tar_render_rep(
#     report, "sector_report.Rmd",
#     params = tibble::tibble(input_dataset = combine_data,
#                             sector_flag = c(15, 16, 17, 18, 19, 20, 21, 22))
#   ),
#
#

  tar_target(summary, summary(combine_data))

)
