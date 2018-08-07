library(UpSetR)

x <- minidream_roster_df %>% 
  filter(SynapseTeamName != "2018 mini-DREAM Admins") %>% 
  mutate(Module = str_split(SubmittedModules, ", ")) %>% 
  unnest(Module) %>%  
  select(Name, Module, SynapseTeamName) %>% 
  replace_na(list(Module = "None"))

modules <- rev(c("Module 0", "Module 1", "Module 2", "Module 3", "Module 4", 
                 "Module 5", "Module 6", "Module 7"))
all <- expand(x, Module, nesting(Name, SynapseTeamName))
head(all)

filter_team <- function(row, team_name) {
  data <- (row["SynapseTeamName"] %in% team_name)
}


all %>% 
  left_join(x %>% mutate(count = 1L)) %>%
  replace_na(list(count = 0L)) %>% 
  spread(Module, count) %>% 
  as.data.frame() %>% 
  upset(
    sets = modules, keep.order = TRUE,
    queries = list(
      # list(
      #   query = elements, 
      #   params = list("SynapseTeamName", "2018 Summer mini-DREAM"), 
      #   color = "blue", 
      #   active = T
      # )
      list(
        query = elements,
        params = list("SynapseTeamName", "2018 CSBC PSON Summer Undergraduate Fellows"),
        color = "#E69F00",
        active = T
      )
      # list(
      #   query = elements, 
      #   params = list("SynapseTeamName", "2018 mini-DREAM Admins"), 
      #   color = "red", 
      #   active = F
      # )
    )
  )
