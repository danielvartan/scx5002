# Reproduction of Figure 3 from Newman, 2005
#
# @author Daniel Vartanian
# @date 2022-12-07
#
# @references
# 
# Newman, M. E. J. (2005). Power laws, Pareto distributions and Zipf's law. 
# Contemporary Physics, 46(5), 323-351. 
# https://doi.org/10.1080/00107510500052444

import matplotlib.pyplot as plt
import numpy as np
import random

def f(x, r, alpha): return(x * ((1 - r) ** (- 1 / (alpha - 1))))

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
    
    # bin_intervals = []
    # 
    # for i in range(len(bin_list)):
    #     if i == len(bin_list) - 1:
    #         pass
    #     else:
    #         bin_intervals.append([bin_list[i], bin_list[i + 1]])
    # 
    # weights = []
    # 
    # for i in y:
    #     for j in bin_intervals:
    #         if (i >= j[0] and i < j[1]):
    #             weights.append((j[0] + j[1]) / 2)
    # 
    # weights = np.array(weights)
    # y_binned = np.histogram(y, bins = bin_list, density = True,
    #            weights = weights)[0]
    
    y_hist = np.histogram(y, bins = bin_list, density = False)
    y_binned = y_hist[0] / np.diff(y_hist[1])
    y_bineed = y_binned / sum(y_binned)
    x_bins = np.array(bin_list[0:(len(bin_list) - 1)])
    
    return([x_bins, y_binned])

def plot_pl(x_1, y_1, x_2, y_2):
    fmt = "r-"
    linewidth = 0.75
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
    # ax2.ticklabel_format(axis = "x", style = "plain")
    # ax2.set_xticks([1.0, 10.0, 100.0])
    # ax2.set_xticklabels(["1", "10", "100"])
    ax2.set_xlabel(xlabel)
    ax2.set_ylabel(ylabel)
    ax2.text(x = 7.5, y = 0.10, s = "(b)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    ax3.plot(x_2, y_2, fmt, linewidth = linewidth)
    ax3.set_xlim(1)
    ax3.set_ylim(10 ** - 9)
    ax3.set_xscale("log")
    ax3.set_yscale("log")
    # ax3.ticklabel_format(axis = "x", style = "plain")
    # ax3.set_xticks([1.0, 10.0, 100.0])
    # ax3.set_xticklabels(["1", "10", "100"])
    ax3.set_xlabel(xlabel)
    ax3.set_ylabel(ylabel)
    ax3.text(x = 25, y = 0.05, 
             s = "(c)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    ax4.plot(x_1, y_1, fmt, linewidth = linewidth)
    ax4.set_xlim(1, 199)
    ax4.set_xscale("log")
    ax4.set_yscale("log")
    # ax4.ticklabel_format(axis = "x", style = "plain")
    # ax4.set_xticks([1.0, 10.0, 100.0])
    # ax4.set_xticklabels(["1", "10", "100"])
    ax4.set_xlabel(xlabel)
    ax4.set_ylabel(ylabel)
    ax4.text(x = 7.5, y = 0.10, s = "(b)", horizontalalignment = "left", 
             verticalalignment = "bottom")
    
    plt.show()

data_1 = pl_1(n = 10 ** 6, alpha = 2.5, x_min = 1)
data_2 = pl_2(n = 10 ** 6, alpha = 2.5, x_min = 1)

plot_pl(x_1 = data_1[0], y_1 = data_1[1], x_2 = data_2[0], y_2 = data_2[1])



