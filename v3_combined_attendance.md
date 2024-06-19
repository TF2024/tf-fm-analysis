---
title: "v3 combined attendance analysis"
output:
  html_notebook: default
  html_document:
    df_print: paged
  pdf_document: default
---




# Combined thresholds

``` r
# Join 1:1 and group coaching counts
combined_pre_16 <- full_join(unique_pre_16_11s, pre_16_group, by = "upn")
combined_pre_16
```

```
## # A tibble: 579 × 5
##    upn   pre_16_total_11s proportion_11s pre_16_total_group proportion_group
##    <chr>            <int>          <dbl>              <int>            <dbl>
##  1 14896               15           62.5                 NA             NA  
##  2 14897               15           62.5                  3             37.5
##  3 14917               11           45.8                  1             12.5
##  4 14949               17           70.8                  2             25  
##  5 15124               13           54.2                 NA             NA  
##  6 15133               11           45.8                 NA             NA  
##  7 15136                8           33.3                 NA             NA  
##  8 15173               17           70.8                 NA             NA  
##  9 15201               19           79.2                  1             12.5
## 10 15304               17           70.8                  1             12.5
## # ℹ 569 more rows
```

``` r
sum(is.na(combined_pre_16$proportion_group))
```

```
## [1] 61
```


``` r
# Calculate combined threshold
combined_count <- combined_pre_16$pre_16_total_group + combined_pre_16$pre_16_total_11s

combined_pre_16 <- combined_pre_16 %>%
  mutate(combined_proportion = combined_count / 28 * 100)

combined_pre_16
```

```
## # A tibble: 579 × 6
##    upn   pre_16_total_11s proportion_11s pre_16_total_group proportion_group combined_proportion
##    <chr>            <int>          <dbl>              <int>            <dbl>               <dbl>
##  1 14896               15           62.5                 NA             NA                  NA  
##  2 14897               15           62.5                  3             37.5                64.3
##  3 14917               11           45.8                  1             12.5                42.9
##  4 14949               17           70.8                  2             25                  67.9
##  5 15124               13           54.2                 NA             NA                  NA  
##  6 15133               11           45.8                 NA             NA                  NA  
##  7 15136                8           33.3                 NA             NA                  NA  
##  8 15173               17           70.8                 NA             NA                  NA  
##  9 15201               19           79.2                  1             12.5                71.4
## 10 15304               17           70.8                  1             12.5                64.3
## # ℹ 569 more rows
```


``` r
# Create df with proportions only
pre_16_all <- combined_pre_16 %>%
  select(upn, proportion_11s, proportion_group, combined_proportion)
pre_16_all
```

```
## # A tibble: 579 × 4
##    upn   proportion_11s proportion_group combined_proportion
##    <chr>          <dbl>            <dbl>               <dbl>
##  1 14896           62.5             NA                  NA  
##  2 14897           62.5             37.5                64.3
##  3 14917           45.8             12.5                42.9
##  4 14949           70.8             25                  67.9
##  5 15124           54.2             NA                  NA  
##  6 15133           45.8             NA                  NA  
##  7 15136           33.3             NA                  NA  
##  8 15173           70.8             NA                  NA  
##  9 15201           79.2             12.5                71.4
## 10 15304           70.8             12.5                64.3
## # ℹ 569 more rows
```


``` r
# Set categorical ranges
pre_16s_all_proportions_thresholds <- pre_16_all %>%
  mutate(
    category_11s = case_when(
      proportion_11s > 100 ~ 1,
      proportion_11s >= 80 & proportion_11s <= 100 ~ 2,
      proportion_11s >= 60 & proportion_11s < 80 ~ 3,
      proportion_11s >= 40 & proportion_11s < 60 ~ 4,
      proportion_11s >= 20 & proportion_11s < 40 ~ 5,
      proportion_11s < 20 ~ 6,
      TRUE ~ NA_integer_
    ),
    category_group = case_when(
      proportion_group > 100 ~ 1,
      proportion_group >= 80 & proportion_group <= 100 ~ 2,
      proportion_group >= 60 & proportion_group < 80 ~ 3,
      proportion_group >= 40 & proportion_group < 60 ~ 4,
      proportion_group >= 20 & proportion_group < 40 ~ 5,
      proportion_group < 20 ~ 6,
      TRUE ~ NA_integer_
    ),
    category_combined = case_when(
      combined_proportion > 100 ~ 1,
      combined_proportion >= 80 & combined_proportion <= 100 ~ 2,
      combined_proportion >= 60 & combined_proportion < 80 ~ 3,
      combined_proportion >= 40 & combined_proportion < 60 ~ 4,
      combined_proportion >= 20 & combined_proportion < 40 ~ 5,
      combined_proportion < 20 ~ 6,
      TRUE ~ NA_integer_
    )
  ) %>%
# Convert categories to factor
  mutate(
    category_11s = factor(category_11s, levels = 1:6),
    category_group = factor(category_group, levels = 1:6),
    category_combined = factor(category_combined, levels = 1:6)
  )

pre_16s_all_proportions_thresholds
```

```
## # A tibble: 579 × 7
##    upn   proportion_11s proportion_group combined_proportion category_11s category_group category_combined
##    <chr>          <dbl>            <dbl>               <dbl> <fct>        <fct>          <fct>            
##  1 14896           62.5             NA                  NA   3            <NA>           <NA>             
##  2 14897           62.5             37.5                64.3 3            5              3                
##  3 14917           45.8             12.5                42.9 4            6              4                
##  4 14949           70.8             25                  67.9 3            5              3                
##  5 15124           54.2             NA                  NA   4            <NA>           <NA>             
##  6 15133           45.8             NA                  NA   4            <NA>           <NA>             
##  7 15136           33.3             NA                  NA   5            <NA>           <NA>             
##  8 15173           70.8             NA                  NA   3            <NA>           <NA>             
##  9 15201           79.2             12.5                71.4 3            6              3                
## 10 15304           70.8             12.5                64.3 3            6              3                
## # ℹ 569 more rows
```

# Merge with follow-up status

``` r
# Merge with follow-up status
pre_16s_all_status <- pre_16s_all_proportions_thresholds %>% left_join(all_records_with_y12q1, by = "upn")
n_distinct(pre_16s_all_status$upn)
```

```
## [1] 579
```

``` r
pre_16s_all_status
```

```
## # A tibble: 4,703 × 10
##    upn   proportion_11s proportion_group combined_proportion category_11s category_group category_combined class followup_period status 
##    <chr>          <dbl>            <dbl>               <dbl> <fct>        <fct>          <fct>             <chr> <fct>           <fct>  
##  1 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y12-Q1          EET    
##  2 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y12-Q2          Unknown
##  3 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y12-Q3          Unknown
##  4 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y12-Q4          Unknown
##  5 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y13-Q1          EET    
##  6 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y13-Q2          NEET   
##  7 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y13-Q3          EET    
##  8 14896           62.5             NA                  NA   3            <NA>           <NA>              2023  Y13-Q4          Unknown
##  9 14897           62.5             37.5                64.3 3            5              3                 2023  Y12-Q1          EET    
## 10 14897           62.5             37.5                64.3 3            5              3                 2023  Y12-Q2          EET    
## # ℹ 4,693 more rows
```


``` r
# Exclude UPNs where combined proportion is NA (i.e. group coaching record is missing)
pre_16s_excl_na <- pre_16s_all_status %>%
  filter(!is.na(combined_proportion)) %>%
  # Select the follow-up periods of interest
  filter(followup_period %in% c("Y12-Q1", "Y13-Q1", "Y13-Q4", "Y14-Q2"))
n_distinct(pre_16s_excl_na$upn)
```

```
## [1] 516
```
# Prepare data for plotting

``` r
# Define category labels
pre_16s_excl_na$category_11s <- factor(pre_16s_excl_na$category_11s,
  levels = 1:6,
  labels = c(">100%", "80% - 100%", "60% - 79%", "40% - 59%", "20% - 39%", "<20%")
)

pre_16s_excl_na$category_group <- factor(pre_16s_excl_na$category_group,
  levels = 1:6,
  labels = c(">100%", "80% - 100%", "60% - 79%", "40% - 59%", "20% - 39%", "<20%")
)

pre_16s_excl_na$category_combined <- factor(pre_16s_excl_na$category_combined,
  levels = 1:6,
  labels = c(">100%", "80% - 100%", "60% - 79%", "40% - 59%", "20% - 39%", "<20%")
)
pre_16s_excl_na
```

```
## # A tibble: 1,464 × 10
##    upn   proportion_11s proportion_group combined_proportion category_11s category_group category_combined class followup_period status 
##    <chr>          <dbl>            <dbl>               <dbl> <fct>        <fct>          <fct>             <chr> <fct>           <fct>  
##  1 14897           62.5             37.5                64.3 60% - 79%    20% - 39%      60% - 79%         2023  Y12-Q1          EET    
##  2 14897           62.5             37.5                64.3 60% - 79%    20% - 39%      60% - 79%         2023  Y13-Q1          EET    
##  3 14897           62.5             37.5                64.3 60% - 79%    20% - 39%      60% - 79%         2023  Y13-Q4          Unknown
##  4 14917           45.8             12.5                42.9 40% - 59%    <20%           40% - 59%         2023  Y12-Q1          EET    
##  5 14917           45.8             12.5                42.9 40% - 59%    <20%           40% - 59%         2023  Y13-Q1          Unknown
##  6 14917           45.8             12.5                42.9 40% - 59%    <20%           40% - 59%         2023  Y13-Q4          Unknown
##  7 14949           70.8             25                  67.9 60% - 79%    20% - 39%      60% - 79%         2024  Y12-Q1          EET    
##  8 15201           79.2             12.5                71.4 60% - 79%    <20%           60% - 79%         2024  Y12-Q1          EET    
##  9 15304           70.8             12.5                64.3 60% - 79%    <20%           60% - 79%         2024  Y12-Q1          EET    
## 10 15313           70.8             12.5                64.3 60% - 79%    <20%           60% - 79%         2024  Y12-Q1          EET    
## # ℹ 1,454 more rows
```

``` r
# Get the total number of unique UPNs per follow-up period
total_upns_per_followup <- pre_16s_excl_na %>%
  group_by(followup_period) %>%
  summarise(total_unique_upns = n_distinct(upn), .groups = "drop")
total_upns_per_followup
```

```
## # A tibble: 4 × 2
##   followup_period total_unique_upns
##   <fct>                       <int>
## 1 Y12-Q1                        516
## 2 Y13-Q1                        364
## 3 Y13-Q4                        346
## 4 Y14-Q2                        238
```

# Plots 
## Plotting combined completion rates
### Combined completion: EET

``` r
# Total unique UPNs per follow-up period
pre_16s_combined_EET <- pre_16s_excl_na %>%
  filter(status == "EET") %>%
  group_by(followup_period, category_combined) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
combined_EET_plot <- ggplot(pre_16s_combined_EET, aes(x = followup_period, y = proportion, fill = as.factor(category_combined))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "magma", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "EET: Total programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### Combined completion: NEET

``` r
# Total unique UPNs per follow-up period
pre_16s_combined_NEET <- pre_16s_excl_na %>%
  filter(status == "NEET") %>%
  group_by(followup_period, category_combined) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
combined_NEET_plot <- ggplot(pre_16s_combined_NEET, aes(x = followup_period, y = proportion, fill = as.factor(category_combined))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "magma", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "NEET: Total programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### Combined completion: Unknown

``` r
# Total unique UPNs per follow-up period
pre_16s_combined_unknown <- pre_16s_excl_na %>%
  filter(status == "Unknown") %>%
  group_by(followup_period, category_combined) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
combined_unknown_plot <- ggplot(pre_16s_combined_unknown, aes(x = followup_period, y = proportion, fill = as.factor(category_combined))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "magma", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "Unknown: Total programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

## Plotting 1:1 completion rates
### 1:1 completion: EET

``` r
# Total unique UPNs per follow-up period
pre_16s_11s_EET <- pre_16s_excl_na %>%
  filter(status == "EET") %>%
  group_by(followup_period, category_11s) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
EET_plot_11s <- ggplot(pre_16s_11s_EET, aes(x = followup_period, y = proportion, fill = as.factor(category_11s))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "EET: 1:1 programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### 1:1 completion: NEET

``` r
# Total unique UPNs per follow-up period
pre_16s_11s_NEET <- pre_16s_excl_na %>%
  filter(status == "NEET") %>%
  group_by(followup_period, category_11s) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
NEET_plot_11s <- ggplot(pre_16s_11s_NEET, aes(x = followup_period, y = proportion, fill = as.factor(category_11s))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "NEET: 1:1 programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### 1:1 completion: Unknown

``` r
# Total unique UPNs per follow-up period
pre_16s_11s_unknown <- pre_16s_excl_na %>%
  filter(status == "Unknown") %>%
  group_by(followup_period, category_11s) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
unknown_plot_11s <- ggplot(pre_16s_11s_unknown, aes(x = followup_period, y = proportion, fill = as.factor(category_11s))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "Unknown: 1:1 programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

## Plotting group coaching completion 
### Group coaching completion: EET

``` r
# EET - group coaching: total count
pre_16s_group_EET <- pre_16s_excl_na %>%
  filter(status == "EET") %>%
  group_by(followup_period, category_group) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
EET_plot_group <- ggplot(pre_16s_group_EET, aes(x = followup_period, y = proportion, fill = as.factor(category_group))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "EET: group coaching programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### Group coaching completion: NEET

``` r
# NEET - group coaching: total count
pre_16s_group_NEET <- pre_16s_excl_na %>%
  filter(status == "NEET") %>%
  group_by(followup_period, category_group) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
NEET_plot_group <- ggplot(pre_16s_group_NEET, aes(x = followup_period, y = proportion, fill = as.factor(category_group))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "NEET: group coaching programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```

### Group coaching completion: Unknown

``` r
# Unknown - group coaching: total count
pre_16s_group_unknown <- pre_16s_excl_na %>%
  filter(status == "Unknown") %>%
  group_by(followup_period, category_group) %>%
  summarise(unique_count = n_distinct(upn), .groups = "drop") %>%
  left_join(
    pre_16s_excl_na %>%
      group_by(followup_period) %>%
      summarise(total_unique_upns = n_distinct(upn), .groups = "drop"),
    by = "followup_period"
  ) %>%
  mutate(proportion = unique_count / total_unique_upns)

# Plot
unknown_plot_group <- ggplot(pre_16s_group_unknown, aes(x = followup_period, y = proportion, fill = as.factor(category_group))) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.05), limits = c(0, 0.5)) +
  scale_fill_viridis_d(begin = 0.2, end = 0.8, direction = 1) +
  labs(
    title = "Unknown: group coaching programme promise completion by follow-up status",
    x = "Follow-up period",
    y = "Proportion of UPNs (%)",
    fill = "Completion threshold"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text())
```
