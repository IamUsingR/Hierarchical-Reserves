data {
  int<lower=0> N_yr;
  int<lower=0> N_age;
  int<lower=0> N;
  int<lower=0> w[N];
  int<lower=0> d[N]; 
  real<lower=1> prem[N_yr];
  real<lower=0> loss[N];
}

transformed data {
  int<lower=0> d_rev[N];
  for (i in 1:N) {
    d_rev[i] <- N_age - d[i] + 1;
  }
}
 
parameters {
  real<lower=-5, upper=5> beta_d[N_age - 1];
  real<lower=-1, upper = .5> logelr;
  real<lower=0, upper = 1> a_d[N_age];
  real alpha_w[N_yr];
}
transformed parameters {
  positive_ordered[N_age] sigma_d;
  for (i in 1:N_age) {
      sigma_d[i] <- 0;
  }  
  for (i in 1:N_age) {
    for (j in i:N_age) {
      sigma_d[N_age - i + 1] <- sigma_d[N_age - i + 1] + a_d[j];
    }
  } 
}
model {
  real mu[N];
  a_d ~ uniform(.00001, 1);
  logelr ~ uniform(-1, .5);
  beta_d ~ uniform(-5, 5); 
  for (i in 1:N_yr) {
    alpha_w[i] ~ normal(prem[i] + logelr , 3.162);
  } 

  for (i in 1:N) {
    if (d[i] < N_age)
      mu[i] <- alpha_w[w[i]] + beta_d[d[i]];
    else 
      mu[i] <- alpha_w[w[i]];
  } 

  loss ~ lognormal(mu, sigma_d[d_rev]);
}
generated quantities {
  real<lower=0> c_wn[N_yr];
  for (i in 1:N_yr) {
    c_wn[i] <- lognormal_rng(alpha_w[i], sigma_d[1]);
  }
}