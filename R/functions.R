
# Prune college scorecard data
prune_cs <- function(cs_data) {
  cs_data <- cs_data[, c("UNITID", "OPEID", "OPEID6",
                         names(cs_data)[33:61])]

}

prune_ipeds_enroll <- function(ipeds_enroll) {
  ipeds_enroll <- ipeds_enroll[ipeds_enroll$EFFYALEV == 1,]
  return(ipeds_enroll)

}

prune_ipeds_inst_char <- function(ipeds_inst_char) {
  ipeds_inst_char$DUNS <- NULL
  # Remove hospitals
  ipeds_inst_char <- ipeds_inst_char[ipeds_inst_char$HOSPITAL != 1,]
  return(ipeds_inst_char)


}


