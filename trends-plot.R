library(lissyrtools)
library(tidyverse)

variables <- c("hours1", "iso2", "year", "sex", "pwgt", "marital", "age")
countries <- c("lu", "be", "fr", "de", "es", "ie", "pl")
country_names <- c(
  lu = "Luxembourg",
  be = "Belgium",
  fr = "France",
  de = "Germany",
  es = "Spain",
  ie = "Ireland"
)

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
            agew    = age >= 20 & age <= 55,
            treat   = as.integer(iso2 == "lu" & year >= 2018)) |>
  mutate(country = factor(country,
                          levels = names(country_names),
                          labels = unname(country_names)))

# Plot 1

p1_data <- lis_all |>
  filter(!is.na(hours), hours >= 0, !is.na(weight),
         female == 1, agew, married) |>
  group_by(country, year) |>
  summarise(mean_hours = weighted.mean(hours, w = weight, na.rm = TRUE),
            n_cell     = n(),
            .groups    = "drop")

p1 <- ggplot(p1_data, aes(x = year, y = mean_hours, color = country)) +
  geom_line(linewidth = 0.5) +
  geom_point(size = 1) +
  geom_vline(xintercept = 2018, linetype = "dashed", linewidth = 0.3) +
  scale_x_continuous(breaks = 2012:2023, limits = c(2012, 2023)) +
  labs(
      # title = "Hours Worked (Main Job) of partnered women aged 20–55",
       x = "Year", y = "Mean weekly hours (weighted)", color = "Country") +
  theme_minimal()

print(png(file = paste0(USR_PDF, "/p1.png"),
          width = 2000, height = 1500, res = 300))
print(p1)
dev.off()