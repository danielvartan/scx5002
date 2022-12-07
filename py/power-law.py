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

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import random
# from scipy.interpolate import make_interp_spline

def f(x, r, alpha): return(x * ((1 - r) ** (- 1 / (alpha - 1))))

def pl(n = 10 ** 6, alpha = 2.5, x_min = 1):
    y = [f(x_min, random.uniform(0, 1), alpha) for i in range(n)]
    # y = [random.paretovariate(alpha) for i in range(n)]
    
    y = np.array(y)
    bin_width = 0.1 # 0.1
    bin_list = [1 + (i * bin_width) for i in range(round(y.max() / bin_width))]
    y_binned = np.histogram(y, bins = bin_list, density = True)[0]
    x_bins = np.array([1 + (i * bin_width) for i in range(1, len(y_binned) + 1)])
    
    # x_y_spline = make_interp_spline(x_bins, y_binned)
    # x_ = np.linspace(x_bins.min(), x_bins.max(), 500)
    # y_ = x_y_spline(x_)
    # ax.plot(x_, y_)
    
    return([x_bins, y_binned])

def plot_pl(x, y, fmt = "r-", xlabel = "$x$", ylabel = "Probability density", 
            xlim = None, ylim = None, log_log = False, text_x_fct = 0.3,
            text_y_fct = 0.8, text_s = "(a)"):
    x = np.array(x)
    y = np.array(y)
    
    plt.clf()
    fig, ax = plt.subplots()
    ax.plot(x, y, fmt)
    ax.set_xlabel(xlabel, fontsize = 10)
    ax.set_ylabel(ylabel, fontsize = 10)
    
    if xlim != None:
        if len(xlim) == 1:
            ax.set_xlim(xlim[0])
        else:
            ax.set_xlim(xlim[0], xlim[1])
    
    if ylim != None:
        if len(ylim) == 1:
            ax.set_ylim(xlim[0])
        else:
            ax.set_ylim(ylim[0], xlim[1])
    
    if log_log == True:
        ax.set_xscale("log")
        ax.set_yscale("log")
        ax.ticklabel_format(axis = "x", style = "plain")
        # ax.set_xticks([1.0, 10.0, 100.0])
        # ax.set_xticklabels(["1", "10", "100"])
    
    if text_s != None:
        if xlim == None:
            x_max = x.max()
        else:
            x_max = x.max() if len(xlim) == 1 else xlim[1]
        
        if ylim == None:
            y_max = y.max()
        else:
            y_max = y.max() if len(ylim) == 1 else ylim[1]

        ax.text(x = text_x_fct * x_max, y = text_y_fct * y_max, s = text_s, 
                horizontalalignment = "right", verticalalignment = "bottom", 
                fontsize = 10)
            
    plt.show()

data = pl(n = 10 ** 6, alpha = 2.5, x_min = 1)

# (a)
plot_pl(x = data[0], y = data[1], xlim = [0, 8], ylim = [0], log_log = False,
        text_x_fct = 0.3, text_y_fct = 0.8, text_s = "(a)")

# (b)
plot_pl(x = data[0], y = data[1], xlim = [1, 199], log_log = True,
        text_x_fct = 0.0245, text_y_fct = 0.08, text_s = "(b)")

