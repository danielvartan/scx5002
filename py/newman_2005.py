# Reproduction of Figure 3 from the Newman (2005) article
#
# @author Daniel Vartanian
# @date 2022-12-07
#
# @references
# 
# Newman, M. E. J. (2005). Power laws, Pareto distributions and Zipf's law. 
# _Contemporary Physics_, _46_(5), 323-351. 
# https://doi.org/10.1080/00107510500052444

import math
import matplotlib.pyplot as plt
import matplotlib.spines as spines
import numpy as np
import random

# # See 'plt.style.available' (defaul = "default").
plt.style.use("default")

def f(x, r, alpha): return(x * ((1 - r) ** (- 1 / (alpha - 1))))

def g(x, c, alpha): return((c / (alpha - 1)) * x ** (- (alpha - 1)))

def alp(x, x_min, n):
    sigma = [math.log(x[i] / x_min) for i in range(n)]
    
    return(1 + n * ((sum(sigma)) ** - 1))

def pl_1(n = 10 ** 6, alpha = 2.5, x_min = 1):
    y = [f(x_min, random.uniform(0, 1), alpha) for i in range(n)]

    y = np.array(y)
    bin_width = 0.1
    bin_list = [1 + (i * bin_width) for i in range(round(y.max() / bin_width))]
    y_binned = np.histogram(y, bins = bin_list, density = True)[0]
    x_bins = np.array(bin_list[0:(len(bin_list) - 1)])
    
    return([x_bins, y_binned])

def pl_2(n = 10 ** 6, alpha = 2.5, x_min = 1):
    y = [f(x_min, random.uniform(0, 1), alpha) for i in range(n)]
    y = np.array(y)
    
    bin_width = 0.1
    bin_list = [1, 1.1]
    multiplier = 2 # 2 (> 1)
    
    while bin_list[-1] <= y.max():
        bin_width = multiplier * bin_width
        bin_list.append(bin_list[-1] + bin_width)

    y_hist = np.histogram(y, bins = bin_list, density = False)
    y_binned = y_hist[0] / np.diff(y_hist[1])
    y_binned = y_binned / sum(y_binned)
    x_bins = np.array(bin_list[0:(len(bin_list) - 1)])
    
    return([x_bins, y_binned])

def pl_3(n = 10 ** 6, alpha = 2.5, x_min = 1):
     # ~3278 is the highest bin using logarithmic binning (see 'pl_2()').
     dx = 0.002 # 3278 / n = 0.003278
     x = [x_min + (i * dx) for i in range(n)]
     x = np.array(x)
     
     y = [g(i, x_min, alpha) for i in x]
     y = np.array(y)
    
     return([x, y])

def plot_pl(x_1, y_1, x_2, y_2, x_3, y_3):
    fmt = "r-"
    linewidth = 0.5
    plt.rcParams.update({'font.size': 8})
    xlabel = "$x$"
    ylabel = "Sample p. density"
    
    plt.clf()    
    fig, [[ax1, ax2], [ax3, ax4]] = plt.subplots(2, 2)
    plt.subplots_adjust(left = 0.15, bottom = 0.15, right = 0.925, 
                        top = 0.925, wspace = 0.6, hspace = 0.4)

    ax1.plot(x_1, y_1, fmt, linewidth = linewidth)
    ax1.set_xlim(0, 8)
    ax1.set_ylim(0)
    ax1
    ax1.set_xlabel(xlabel)
    ax1.set_ylabel(ylabel)
    ax1.text(x = 3, y = 1.06, s = "(a)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    ax2.plot(x_1, y_1, fmt, linewidth = linewidth)
    ax2.set_xlim(1, 10 ** 2 + (0.1 * 10 ** 3))
    ax2.set_xscale("log")
    ax2.set_yscale("log")
    ax2.set_xlabel(xlabel)
    ax2.set_ylabel(ylabel)
    ax2.text(x = 7.5, y = 0.1, s = "(b)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    ax3.plot(x_2, y_2, fmt, linewidth = linewidth)
    ax3.set_xlim(1, 10 ** 3 + (0.1 * 10 ** 4))
    ax3.set_ylim(10 ** - 9)
    ax3.set_xscale("log")
    ax3.set_yscale("log")
    ax3.set_xlabel(xlabel)
    ax3.set_ylabel(ylabel)
    ax3.text(x = 18, y = 0.003, 
             s = "(c)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    ax4.plot(x_3, y_3, fmt, linewidth = linewidth)
    ax4.set_xlim(1)
    ax4.set_xscale("log")
    ax4.set_yscale("log")
    ax4.set_xlabel(xlabel)
    ax4.set_ylabel(ylabel)
    ax4.text(x = 22, y = 0.05, s = "(d)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    plt.show()

data_1 = pl_1(n = 10 ** 6, alpha = 2.5, x_min = 1)
data_2 = pl_2(n = 10 ** 6, alpha = 2.5, x_min = 1)
data_3 = pl_3(n = 10 ** 6, alpha = 2.5, x_min = 1)

plot_pl(x_1 = data_1[0], y_1 = data_1[1], x_2 = data_2[0], y_2 = data_2[1],
        x_3 = data_3[0], y_3 = data_3[1])
