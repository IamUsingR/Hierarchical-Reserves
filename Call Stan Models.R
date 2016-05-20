### Meyer's LCL model

library(data.table)
library(rstan)

setwd('C:/Projects/Reserving Models/Schedule P Data')
dat <- fread('selected insurer data.csv')

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

setwd('C:/Projects/Reserving Models/Stan Models')


dat_stan <- dat[line == 'WC' & grpcode == 353]
setkey(dat_stan, w, d)
dat_stan[, w1 := .GRP, w]
dat_stan[, d1 := .GRP, d - w]
dat_stan <- dat_stan[w1 + d1 <= max(dat_stan$w1) + 1] 


l_stan <- list(N_yr = length(unique(dat_stan$w))
               , N_age = length(unique(dat_stan$d))
               , N = nrow(dat_stan)
               , w = dat_stan$w1
               , d = dat_stan$d1
               , prem = dat_stan[, .(prem = log(min(net_premium))), .(w)
                                 ][order(w)]$prem
               , loss = dat_stan$cum_incloss)

fname <- 'LCL.stan'
fit <- stan(fname, data = l_stan, chains = 4, control=list(adapt_delta=0.99))
rewdprint(fit)
plot(fit, pars = "sigma_d")
pairs(fit, pars = 'sigma_d')
