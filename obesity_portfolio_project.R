# =========================================
# U.S. Adult Obesity Analysis (CDC PLACES)
# =========================================

# 1. Load packages
library(tidyverse)
library(janitor)

# 2. Import data
places <- read_csv(file.choose())

# 3. Clean and filter data
# Keep only age-adjusted adult obesity prevalence for 2023
obesity_data <- places %>% 
  filter(Measure == "Obesity among adults",
         Data_Value_Type == "Age-adjusted prevalence",
         Year == 2023) %>% 
  select(Year, StateAbbr, StateDesc, LocationName,
         Measure, Data_Value, TotalPop18plus)

# Remove duplicate counties
obesity_data <- obesity_data %>% 
  distinct(StateDesc, LocationName, .keep_all = TRUE)

# =========================
# 4. Distribution analysis
# =========================

# Histogram of county-level obesity
hist_plot <- ggplot(obesity_data, aes(x = Data_Value)) +
  geom_histogram(bins = 30) +
  labs(title = "Distribution of Adult Obesity Prevalence Across U.S. Counties",
       x = "Adult obesity prevalence (%)",
       y = "Number of counties") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

print(hist_plot)

# Summary stats
mean_obesity <- mean(obesity_data$Data_Value, na.rm = TRUE)
print(mean_obesity)

# Interpretation:
# Most counties cluster around the upper 30% range for adult obesity prevalence.

# =========================
# 5. State-level analysis
# =========================

state_obesity_data_summary <- obesity_data %>% 
  group_by(StateDesc) %>% 
  summarise(avg_obesity_per_state = mean(Data_Value, na.rm = TRUE)) %>% 
  arrange(desc(avg_obesity_per_state))

print(head(state_obesity_data_summary))
print(tail(state_obesity_data_summary))

# =========================
# 6. State visualization
# =========================

state_plot <- ggplot(state_obesity_data_summary,
                     aes(x = reorder(StateDesc, avg_obesity_per_state),
                         y = avg_obesity_per_state)) +
  geom_col() +
  coord_flip() +
  labs(title = "Average Adult Obesity Prevalence by State (Age-Adjusted)",
       x = "State",
       y = "Obesity prevalence (%)") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.y = element_text(size = 7)
  )

# =========================
# 7. Top 10 states
# =========================

top_10_states <- head(state_obesity_data_summary, 10)

top_states_plot <- ggplot(top_10_states,
                          aes(x = reorder(StateDesc, avg_obesity_per_state),
                              y = avg_obesity_per_state)) +
  geom_col() +
  coord_flip() +
  geom_text(aes(label = sprintf("%.1f", avg_obesity_per_state)),
            hjust = -0.1) +
  labs(title = "Top 10 U.S. States by Adult Obesity Prevalence",
       x = "State",
       y = "Obesity prevalence (%)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(top_states_plot)

# =========================
# 8. County-level analysis
# =========================

county_obesity_data_summary <- obesity_data %>% 
  group_by(StateDesc, LocationName) %>% 
  summarise(avg_obesity_per_county = mean(Data_Value, na.rm = TRUE)) %>% 
  arrange(desc(avg_obesity_per_county))

top_10_counties <- head(county_obesity_data_summary, 10)

# Create combined county + state label
top_10_counties <- top_10_counties %>% 
  mutate(county_state = paste0(LocationName, ", ", StateDesc))

# =========================
# 9. Top counties plot
# =========================

top_county_plot <- ggplot(top_10_counties,
                          aes(x = reorder(county_state, avg_obesity_per_county),
                              y = avg_obesity_per_county)) +
  geom_col() +
  coord_flip(clip = "off") +
  geom_text(aes(label = sprintf("%.1f", avg_obesity_per_county)),
            hjust = -0.1) +
  scale_y_continuous(limits = c(0, max(top_10_counties$avg_obesity_per_county) + 4)) +
  labs(title = "Top 10 U.S. Counties by Adult Obesity Prevalence (Age-Adjusted)",
       x = "County",
       y = "Obesity prevalence (%)") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.margin = margin(10, 40, 10, 10)
  )

print(top_county_plot)

# Interpretation:
# The highest-obesity counties are heavily concentrated in Alabama and Mississippi,
# indicating strong regional clustering at the county level.


ggsave("histogram.png", plot = hist_plot, width = 8, height = 5)
ggsave("state_plot.png", plot = state_plot, width = 10, height = 12)
ggsave("top_counties.png", plot = top_county_plot, width = 10, height = 6)



  
