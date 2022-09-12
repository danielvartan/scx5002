library(dplyr)
library(magrittr)
library(ggplot2)

logistic_map <- function(x, R = 2) R * (x - x^2)

R <- 2
x = 0.2
steps <- 100

data <- dplyr::tibble(t = 1, x = x)

for (i in seq(2, steps)) {
    data <- data %>%
        dplyr::rows_insert(
            dplyr::tibble(t = i, x = logistic_map(data$x[i - 1], R)),
            by = "t"
        )
}

data <- data %>% dplyr::mutate(y = dplyr::lag(data$x))

## Logistic map
ggplot2::qplot(x, y, data = data, geom = "line", xlab = "x_t", ylab = "x_t+1",
               colour = "red", na.rm = TRUE)

## Logistic function
ggplot2::ggplot(dplyr::tibble(x = seq(0, 1)), ggplot2::aes(x)) +
    ggplot2::geom_function(fun = logistic_map, colour = "red")

## Logistic trajectory
ggplot2::qplot(t, x, data = data, geom = "line", xlab = "t (step)",
               ylab = "x_t", colour = "red", na.rm = TRUE)
