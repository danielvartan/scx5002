import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

def f_exact(lam, lam_c, k, tau, tau_ref = 24):
    log_f = (tau_ref - tau) / (1 + np.exp(1) ** (- k * (lam - lam_c)))
    out = tau + log_f

    return(out)

def exact(f, lam_c, k, tau, lam_0 = 0, lam_n = 10, h = 10 ** (- 3)):
    lam_list, y_list = [lam_0], [f(lam_0, lam_c, k, tau)]
    
    while lam_0 < lam_n:
        x_next = lam_0 + h
        y_next = f(x_next, lam_c, k, tau)
        lam_0 = x_next
        lam_list.append(x_next)
        y_list.append(y_next)
    
    return [lam_list, y_list]

def plot_exact(f, lam_c = 5, k = 2, tau = 22, lam_0 = 0, lam_n = 10, 
               h = 10 ** (- 3)):
    exact_data = exact(f, lam_c, k, tau, lam_0, lam_n)

    title = ("$\\lambda_c = {lam_c}$, $k = {k}$, $\\tau = {tau}$")\
         .format(lam_c = str(lam_c), k = str(k), tau = str(tau))

    plt.rcParams.update({'font.size': 10})
    plt.clf()
    
    fig, ax = plt.subplots()
    ax.plot(exact_data[0], exact_data[1], "r-", linewidth = 1)
    ax.set_xlabel("$\\lambda$")
    ax.set_ylabel("$f(\\lambda, \\lambda_{c}, k, \\tau)$")
    ax.set_title(title, fontsize = 10)
    plt.show()

plot_exact(f_exact, lam_c = 5, k = 2, tau = 22, lam_0 = 0, lam_n = 10)
plot_exact(f_exact, lam_c = 5, k = 2, tau = 26, lam_0 = 0, lam_n = 10)

def labren(id, name = None,
           file = "./data/labren/global_horizontal_means.csv"):
    data = (
    pd.read_csv(filepath_or_buffer  = file, sep = ";")
    .rename(str.lower, axis = "columns")
    .loc[[id - 1]]
    )
    
    out = {"name": name}
    
    for i in list(data):
        out[i] = data.loc[id - 1, i]
    
    data = (
        data.iloc[:, 5:17]
        .transpose()
    )

    data.reset_index(inplace = True)
    data.columns = ["date", "x"]
    
    out["ts"] = list(data["x"])
    
    return(out)

def plot_labren(id_1_index = 72272, id_2_index = 1, 
                name_1 = "Nascente do rio Ailã", name_2 = "Arroio Chuí", 
                label_1 = "Nascente do rio Ailã (Lat.: $5.272$)",
                label_2 = "Arroio Chuí (Lat.: $- 33.752$)"):
    x = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
         "Oct", "Nov", "Dec"]
    data_1 = labren(id_1_index, name_1)
    data_2 = labren(id_2_index, name_2)
    
    title = "Global Horizontal Solar Irradiation (Source: LABREN/INPE, 2017)"
    
    plt.rcParams.update({'font.size': 10})
    plt.clf()
    
    fig, ax = plt.subplots()
    ax.plot(x, data_1["ts"], "r-", label = label_1, linewidth = 1)
    ax.plot(x, data_2["ts"], "b-", label = label_2,  linewidth = 1)
    ax.set_xlabel("Month")
    ax.set_ylabel("$Wh / m^{2}.day$")
    ax.set_title(title, fontsize = 10)
    
    plt.legend(fontsize = 8)
    plt.show()

plot_labren()

def entrain(lam, lam_c, k, tau, tau_ref = 24):
    log_f = (tau_ref - tau) / (1 + np.exp(1) ** (- k * (lam - lam_c)))
    out = tau + log_f
    error = np.random.uniform(low = 0, high = 1) * np.abs(out - tau)
    
    if out >= tau:
        out = out - error
    else:
        out = out + error
    
    return(out)

def entrain_turtles(turtles, turtles_0, lam, lam_c, lam_c_tol):
    n = len(turtles)
    out = []
    
    for i in range(n):
        tau_0 = turtles_0[i][0]
        tau = turtles[i][0]
        k = turtles[i][1]
        
        if (lam >= (lam_c - lam_c_tol)):
            out.append((entrain(lam, lam_c, k, tau, tau_ref = 24), k))
        else:
            out.append((entrain(lam, lam_c, k, tau, tau_ref = tau_0), k))
    
    return(out)

# np.array(labren(72272)["ts"]).mean() ~ 4727.833 
def compute_model(n = 10 **2, tau_range = (23.5, 24.6), tau_mean = 24.15, 
                  tau_dp = 0.2, k_range = (0.001, 0.01), k_mean = 0.001, 
                  k_dp = 0.005, lam_c = 4727.833 , lam_c_tol = 1000, 
                  labren_id = 1, plot = True):
    turtles_0 = []
    
    for i in range(n):
        tau = np.random.normal(tau_mean, tau_dp)
        k = np.random.normal(k_mean, k_dp)
        
        if (tau < tau_range[0]): tau = tau_range[0]
        if (tau > tau_range[1]): tau = tau_range[1]
        if (k < k_range[0]): k = k_range[0]
        if (k > k_range[1]): k = k_range[1]
        
        turtles_0.append((tau, k))
    
    labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", 
              "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    turtles_by_month = {"Unentrain": turtles_0}
    
    for i in range(12):
        key = list(turtles_by_month)[-1]
        lam = labren(labren_id)["ts"][i]
        turtles_i = entrain_turtles(
            turtles_by_month[key], turtles_0, lam, lam_c, lam_c_tol = lam_c_tol
            )
        turtles_by_month[labels[i]] = turtles_i
    
    seasons = [["Dec", "Jan", "Feb"], ["Mar", "Apr", "May"],
               ["Jun", "Jul", "Aug"], ["Sep", "Oct", "Nov"]]
    labels = ["Summer", "Autumn", "Winter", "Spring"]

    turtles_by_season = {"Unentrain": turtles_0}
    
    for i in range(4):
        key = list(turtles_by_season)[-1]
        lam = np.mean([labren(labren_id)[i.lower()] for i in seasons[i]])
        turtles_i = entrain_turtles(
            turtles_by_season[key], turtles_0, lam, lam_c, lam_c_tol = lam_c_tol
            )
        turtles_by_season[labels[i]] = np.array(turtles_i)
    
    if plot == True: 
        plot_model_density(turtles_by_season, lam_c, labren_id)

    return([turtles_by_month, turtles_by_season])

def plot_model_density(turtles, lam_c, labren_id):
    lat = labren(labren_id)["lat"]
    labels = ["Unentrain", "Summer", "Autumn", "Winter", "Spring"]
    colors = ["#f98e09", "#bc3754", "#57106e", "#5ec962"]
    
    title = ("$\\lambda_c = {lam_c}$, Latitude = ${lat}$")\
             .format(lam_c = str(lam_c), lat = str(lat))
    
    plt.rcParams.update({'font.size': 10})
    plt.clf()
    fig, ax = plt.subplots()
    
    for i, j in enumerate(turtles):
        tau_i = np.array(turtles[j])[:, 0]
        n = len(tau_i)
        
        if (i == 0):
            color = "black"
            linewidth = 3
        else:
            color = colors[i - 1]
            linewidth = 1
        
        sns.kdeplot(tau_i, color = color, label = labels[i], 
                    linewidth = linewidth, warn_singular = False)

    ax.set_xlabel("$\\tau$")
    ax.set_ylabel("Kernel Density Estimate (KDE)")
    ax.set_xlim(23.5, 24.6)
    ax.set_title(title, fontsize = 10)
    
    plt.legend(fontsize = 8)
    plt.show()

labren(72272)
compute_model(labren_id = 72272, )

labren(1)
compute_model(labren_id = 1)

def invisible(x): return(print("Ignore this message."))

def merge_dict(dict_1, dict_2):
    out = {}
    
    for i, j in enumerate(dict_1):
        out[j] = np.append(np.array(dict_1[j]), np.array(dict_1[j]), axis = 0)
        
    return(out)

def model(n = 10 **2, tau_range = (23.5, 24.6), tau_mean = 24.15, 
          tau_dp = 0.2, k_range = (0.001, 0.01), k_mean = 0.001, 
          k_dp = 0.005, lam_c = 4727.833, lam_c_tol = 1000, labren_id = 1, 
          r = 3, plot = True):
    turtles_by_month_n, turtles_by_season_n = {}, {}
    
    for i in range(r):
        model_i = compute_model(
            n, tau_range, tau_mean, tau_dp, k_range, k_mean, k_dp, lam_c, 
            lam_c_tol, labren_id, plot = False
            )
        
        label = "r_" + str(i + 1)
        turtles_by_month_n[label] = model_i[0]
        turtles_by_season_n[label] = model_i[1]
    
    turtles_by_month_mean = {}
    
    for i, j in enumerate(turtles_by_month_n):
        for k, l in enumerate(turtles_by_month_n[j]):
            try:
                invisible(turtles_by_month_mean[l])
            except:
                turtles_by_month_mean[l] = turtles_by_month_n[j][l]
            else:
                turtles_by_month_mean[l] = [turtles_by_month_mean[l],
                turtles_by_month_n[j][l]]
    
    
    

