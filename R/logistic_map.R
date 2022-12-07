library(checkmate)
library(cli)
library(dplyr)
library(magrittr)
library(ggplot2)
library(ggpubr)
library(purrr)

logistic_map <- function(x, R) {
    checkmate::assert_number(x, lower = 0, upper = 1)
    checkmate::assert_number(R, lower = 0)
    
    R * (x - x^2)
} 

iterate_lm <- function(x, R, steps = 100) {
    checkmate::assert_number(x, lower = 0, upper = 1)
    checkmate::assert_number(R, lower = 0)
    checkmate::assert_integerish(steps, lower = 2)
    
    data <- dplyr::tibble(t = 1, x = x)
    
    for (i in seq(2, steps)) {
        data <- data %>%
            dplyr::rows_insert(
                dplyr::tibble(t = i, x = logistic_map(data$x[i - 1], R)),
                by = "t"
            )
    }
    
    data %>% dplyr::mutate(y = dplyr::lead(x))
}

R <- 4
x_1 = 0.2
x_2 = 0.2000001
steps <- 100

data_1 <- iterate_lm(x_1, R, steps)
data_2 <- iterate_lm(x_2, R, steps)

## Logistic map/State of the system (data_1)
state_1 <- ggplot2::ggplot() +
    ggplot2::geom_function(
        mapping = ggplot2::aes(x),
        data = dplyr::tibble(x = seq(0, 1)),
        fun = logistic_map, args = list(R = R),
        colour = "gray", size = 1
        ) +
    ggplot2::geom_point(
        data = data_1, mapping = ggplot2::aes(x = x, y = y),
        colour = "red", size = 5, shape = 21, na.rm = TRUE,
        position = ggplot2::position_jitter(width = 0.002, height = 0)
        ) +
    ggplot2::labs(x = "x_t (step)", y = "x_{t + 1}") + 
    ggplot2::lims(x = c(0, 1), y = c(0, 1))

## Logistic trajectory (data_1)
trajectory_1 <- ggplot2::ggplot(data = data_1, ggplot2::aes(x = t, y = x)) +
    ggplot2::geom_line(colour = "red", size = 0.5, na.rm = TRUE) +
    ggplot2::labs(x = "t (step)", y = "x_t") +
    ggplot2::lims(y = c(0, 1))

## Logistic map/State of the system [data_1 (red) & data_2 (blue)]
state_1_2 <- ggplot2::ggplot() +
    ggplot2::geom_function(
        mapping = ggplot2::aes(x),
        data = dplyr::tibble(x = seq(0, 1)),
        fun = logistic_map, args = list(R = R),
        colour = "gray", size = 1
    ) +
    ggplot2::geom_point(
        data = data_1, mapping = ggplot2::aes(x = x, y = y),
        colour = "red", size = 5, shape = 21, na.rm = TRUE,
        position = ggplot2::position_jitter(width = 0.002, height = 0)
    ) +
    ggplot2::geom_point(
        data = data_2, mapping = ggplot2::aes(x = x, y = y),
        colour = "blue", size = 5, shape = 21, na.rm = TRUE,
        position = ggplot2::position_jitter(width = 0.002, height = 0)
    ) +
    ggplot2::labs(x = "x_t (step)", y = "x_{t + 1}") + 
    ggplot2::lims(x = c(0, 1), y = c(0, 1))

## Logistic trajectory [data_1 (red) & data_2 (blue)]
trajectory_1_2 <- ggplot2::ggplot() +
    ggplot2::geom_line(
        data = data_1, mapping = ggplot2::aes(x = t, y = x),
        colour = "red", size = 0.5, na.rm = TRUE) +
    ggplot2::geom_line(
        data = data_2, mapping = ggplot2::aes(x = t, y = x),
        colour = "blue", size = 0.5, na.rm = TRUE) +
    ggplot2::labs(x = "t (step)", y = "x_t") +
    ggplot2::lims(y = c(0, 1))

## Plot charts
ggpubr::ggarrange(state_1, trajectory_1, state_1_2, trajectory_1_2,
          labels = c("A", "B", "C", "D"), ncol = 2, nrow = 2)

## Bifurcation diagram
# find_lm_attractors <- function(R, x, steps = 100, min_f = 2, digits = 5) {
#     checkmate::assert_number(R, lower = 0)
#     checkmate::assert_number(x, lower = 0, upper = 1)
#     checkmate::assert_integerish(steps, lower = 2)
#     checkmate::assert_integerish(digits, lower = 0)
#     
#     data <- iterate_lm(x, R, steps) %>%
#         magrittr::extract2("x") %>%
#         round(digits = digits)
#     
#     attractors <- data %>%
#         table() %>%
#         which(x = . > 2) %>%
#         names() %>%
#         as.numeric()
#     
#     dplyr::tibble(x = x, R = R, attractor = attractors)
# }
# 
# lm_attractors <- function(R_start = 1, R_end = 4, R_step = 0.1, x_start = 0.2,
#                           steps = 100, min_f = 2, digits = 5) {
#     checkmate::assert_integerish(R_start, lower = 0)
#     checkmate::assert_integerish(R_end, lower = 1)
#     checkmate::assert_true(R_start < R_end)
#     checkmate::assert_number(R_step, lower = 0.000001)
#     checkmate::assert_true(R_start + R_step <= R_end)
#     checkmate::assert_number(x_start, lower = 0, upper = 1)
#     checkmate::assert_integerish(steps, lower = 2)
#     checkmate::assert_integerish(min_f, lower = 1)
#     checkmate::assert_integerish(digits, lower = 0)
#     
#     R_seq <- seq(R_start, R_end, by = R_step)
#     
#     # purrr::map_dfr(cli::cli_progress_along(R_seq),
#     #                find_lm_attractors, x = x_start, steps = steps,
#     #                min_f = min_f, digits = digits)
#     
#     purrr::map_dfr(R_seq, find_lm_attractors, x = x_start, steps = steps,
#                    min_f = min_f, digits = digits)
# }
# 
# data_attractors <- lm_attractors()
# 
# ggplot2::ggplot(data = data_attractors, ggplot2::aes(x = R, y = attractor)) +
#     ggplot2::geom_line(colour = "red", size = 0.5, na.rm = TRUE) +
#     ggplot2::labs(x = "R", y = "x") +
#     ggplot2::lims(y = c(0, 1))
