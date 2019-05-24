library(synapser)
library(tidyverse)
library(fuzzyjoin)
library(jsonlite)

# setup -------------------------------------------------------------------

synLogin()
# load roster
roster_file <- "roster.tsv"
roster_df <- read_tsv(roster_file) %>% 
  mutate(SynapseTeamID = as.character(SynapseTeamID))

user_teams <- unique(roster_df$SynapseTeamID) %>% 
  set_names(.)

project <- synGet("syn18813072")
participant_team <- "3390083"


# get team names ----------------------------------------------------------

team_names <- map_df(user_teams, function(team_id) {
  synGetTeam(team_id)$json() %>% 
    fromJSON()
}) %>% 
  select(id, name)

# fetch teams -----------------------------------------------------------

build_member_table <- function(team_id) {
  members <- as.list(synGetTeamMembers(team_id))
  map_df(members, function(x) {
    x$json() %>% 
      fromJSON() %>% 
      pluck("member") %>% 
      as_tibble()
  })
}

all_users <- map_df(user_teams, build_member_table, .id = "teamId") %>% 
  mutate_all(funs(ifelse(. == "", NA, .)))


# augment roster ----------------------------------------------------------

# attempt to search by name
name_match <- all_users %>% 
  mutate(tmp_name = str_c(firstName, lastName, sep = " ")) %>% 
  filter(!is.na(tmp_name)) %>%
  stringdist_left_join(
    mutate(roster_df, Name = str_replace(Name, "\\(.*\\)", "")), 
    ., 
    by = c("Name" = "tmp_name", "SynapseTeamID" = "teamId"), 
    max_dist = 4) %>% 
  filter(str_detect(Name, lastName) | is.na(lastName)) %>% 
  select(-tmp_name, -teamId) %>% 
  distinct()
  # nest(teamId) %>% 
  # mutate(data = map_chr(data, ~ str_c(.x, sep = ","))) %>% 
  # select(-tmp_name, OtherTeamIDs = data)

# attempt to search by email/username
username_match <- all_users %>% 
  mutate(tmp_name = str_c(firstName, lastName, sep = " ")) %>% 
  filter(is.na(tmp_name)) %>%
  stringdist_right_join(
    roster_df %>% 
      filter(!is.na(Email)) %>% 
      mutate(tmp_username = str_replace(Email, "(@|\\.).*", ""),
             tmp_username = ifelse(Name == "Jeffrey Chang",
                                   "jchang", tmp_username)),
    .,
    by = c("tmp_username" = "userName"),
    max_dist = 3) %>%
  select(-tmp_name, -tmp_username, -teamId) 

# combine results
roster_augmented_df <- name_match %>% 
  filter(!(Name %in% username_match$Name)) %>% 
  bind_rows(username_match)

# clean up
roster_augmented_df <- roster_augmented_df %>% 
  select(-isIndividual) %>% 
  left_join(team_names, by = c("SynapseTeamID" = "id")) %>% 
  rename(SynapseID = ownerId, SynapseUserName = userName, 
         SynapseTeamName = name) %>% 
  mutate(JoinedTeam = !is.na(SynapseID))


# check certification -----------------------------------------------------

synGetCertificationStatus <- function(owner_ids) {
  get_certification_status <- function(owner_id) {
    request <- str_glue("/user/{id}/certifiedUserPassingRecord", id = owner_id)
    res <- list(passed = FALSE)
    try(res <- synRestGET(request), silent=TRUE)
    res$passed
  }
  if (is_vector(owner_ids)) {
    map_lgl(owner_ids, get_certification_status)
  } else {
    get_certification_status(owner_id)
  }
}

roster_augmented_df <- roster_augmented_df %>% 
  mutate(Certified = synGetCertificationStatus(SynapseID))

# check registration ------------------------------------------------------

participants <- build_member_table(participant_team)
roster_augmented_df <- roster_augmented_df %>% 
  mutate(Registered = SynapseID %in% participants$ownerId)

# create RStudio usernames ------------------------------------------------

roster_augmented_df <- roster_augmented_df %>% 
  mutate(
    tmp_name = str_replace(Name, "\\(.*\\)", ""),
    tmp_name = str_trim(tmp_name),
    firstName = if_else(is.na(firstName) | firstName == "",
                        str_extract(tmp_name, "^\\w+"), firstName),
    lastName = if_else(is.na(lastName) | lastName == "",
                       str_extract(tmp_name, "\\w+$"), lastName),
    RStudioUserName = str_to_lower(str_c(str_sub(firstName, 1, 1), lastName))
  ) %>% 
  select(-tmp_name, -firstName, -lastName)


# finalize ----------------------------------------------------------------

minidream_roster_df <- roster_augmented_df %>% 
  select(Name, Email, Role, SynapseID, SynapseUserName, Certified,
         SynapseTeamID, SynapseTeamName, JoinedTeam, Registered,
         RStudioUserName)


# check submissions -------------------------------------------------------

source(file.path(here::here("R"), "collect_submissions.R"))
submission_df <- submission_df %>% 
  filter(stringAnnos_module == "Module 6") %>% 
  mutate(SynapseUserName = str_replace(name, "_activity.*", "")) %>% 
  left_join(select(roster_augmented_df, SynapseUserName, SynapseID)) %>% 
  mutate(userId = SynapseID) %>% 
  select(-SynapseUserName, SynapseID) %>% 
  bind_rows(filter(submission_df, stringAnnos_module != "Module 6"))

minidream_roster_df <- minidream_roster_df %>%
  left_join(select(submission_df, userId, stringAnnos_module),
    by = c("SynapseID" = "userId")
  ) %>%
  distinct() %>%
  group_by(Name) %>%
  arrange(stringAnnos_module) %>%
  mutate(
    NumSubmitted = n_distinct(stringAnnos_module, na.rm = TRUE),
    SubmittedModules = str_c(stringAnnos_module, collapse = ", ")
  ) %>%
  ungroup() %>%
  select(-stringAnnos_module) %>%
  distinct()

# create/update Synapse table ---------------------------------------------

as_table_columns <- function(df) {
  col_types <- map(df, typeof)
  syn_type_map <- list(
    character = "STRING", 
    logical = "BOOLEAN", 
    numeric = "DOUBLE", 
    integer = "INTEGER"
  )
  syn_col_types <- map(col_types, function(x) { syn_type_map[[x]] })
  max_lengths <- summarize_all(df, funs(max(str_length(.), na.rm = TRUE) + 50L))
  map(colnames(df), function(col) {
    if (syn_col_types[[col]] == "STRING") {
      Column(name = col, columnType = syn_col_types[[col]],
             maximumSize = max_lengths[[col]])
    } else {
      Column(name = col, columnType = syn_col_types[[col]])
    }
  })
}

project_tables <- synGetChildren(project, includeTypes = list("table")) %>%
  as.list() %>% 
  map_df(~ as_tibble(.x))

if ("2019 mini-DREAM Roster" %in% project_tables$name) {
  table_id <- project_tables %>% 
    filter(name == "2019 mini-DREAM Roster") %>% 
    pluck("id")
  rows_to_delete <- synTableQuery(str_glue("select * from {id}", id = table_id))
  synDelete(rows_to_delete)
  schema <- synGet(table_id)
} else {
  cols <- as_table_columns(minidream_roster_df)
  schema <- Schema(name = '2019 mini-DREAM Roster', 
                   columns = cols, parent = project)
}
table <- Table(schema, minidream_roster_df)
table <- synStore(table)

