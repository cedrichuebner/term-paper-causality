library(lissyrtools)
library(tidyverse)
library(fixest)

variables <- c("hours1", "iso2", "year", "sex", "pwgt", "marital", "age")
countries <- c("lu", "be", "fr", "de", "es", "ie") # Removed Poland because of missing hour variable

lis_datasets <- lissyuse(data = countries, vars  = variables, from = 2012, to = 2023)

names(lis_datasets)

lis_all <- lis_datasets |>
  imap(\(df, nm) df |>
         select(any_of(variables)) |>
         mutate(iso2 = substr(nm, 1, 2),
                year = 2000L + as.integer(substr(nm, 3, 4)))) |>
  bind_rows() |>
  transmute(country = iso2, year,
            female  = as.integer(sex) - 1L,
            hours   = as.numeric(hours1),
            weight  = as.numeric(pwgt),
            married = as.integer(marital) %in% c(100, 110),
            never_married = as.integer(marital) == 210,
            agew    = age >= 20 & age <= 55,
            treat   = as.integer(iso2 == "lu" & year >= 2018))

# Diagnostics

#table(lis_all$treat, useNA = "ifany")
#table(lis_all$country, lis_all$year)
#class(lis_all$marital); attr(lis_all$marital, "labels")
#table(lis_all$married, useNA = "ifany")
#table(lis_all$female, useNA = "ifany")

# Preparing subset for estimating the models

lis_est <- lis_all |> filter(female == 1, married, agew)

# Model 1 (w/o controls)

m1 <- feols (hours ~ treat | country + year, data = lis_est, weights = ~weight, cluster = ~country)

# Robustness checks

# Model 2: Treatment group = married men

lis_est <- lis_all |> filter(female == 0, married, agew)

m2 <- feols (hours ~ treat | country + year, data = lis_est, weights = ~weight, cluster = ~country)

# Model 3: Treatment group = unmarried women

lis_est <- lis_all |> filter(female == 1, never_married, agew)

m3 <- feols (hours ~ treat | country + year, data = lis_est, weights = ~weight, cluster = ~country)

# Model output

models <- list("Baseline" = m1, "Placebo (married men)" = m2, "Placebo (never married women)" = m3)

etable(models, se.below = TRUE, digits = 3,
       fitstat = ~ n + r2 + wr2, drop = "age")

