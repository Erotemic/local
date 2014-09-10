# Bayesian vs Frequentist
#http://www.behind-the-enemy-lines.com/2008/01/are-you-bayesian-or-frequentist-or.html


'''
Summary: 
    Frequentist: What is the probability of the data given there IS a FIXED p. 
    - p is fixed

    Baysian: What is the probability of speicic value of p given the data we SAW. 
    - p is a distribution (because we really just dont know)

'''

import numpy as np
from scipy.special import binom
from scipy.stats import beta
#help(np.random.choice)
#np.random.choice(a, size=1, replace=True, p=None)

# We have an unknown p
p = np.random.rand()
print('We have unknown p. (but I"ll tell you p=%r) ' % p)

print('The actual probability of getting two heads in a row is: %r ' % p**2)

# Have a coin heads:p, tails:(1-p)
coin = {1:p, 0:(1-p)}
a_ = coin.keys()
p_ = coin.values()

# We flip the coin 14 times
nsamp = 14
samples = np.random.choice(a_, size=nsamp, replace=True, p=p_)

num_heads = samples.sum()
total = len(samples) 

print('In a random sample you see the data: ')
print('# heads = %r ' % num_heads)
print('# total = %r ' % total)

# A frequentist approach is to use the frequency as the probability
# The maximum likelihood estimate of p is:
p_freq = num_heads / total
print('According to a frequentist: p_F=%r' % p_freq)

# What is the probability of getting two heads? 
p_two_ones_freq = p_freq**2
print('Pr_F(2 heads | data) = %r' % p_two_ones_freq)

#-------------------------------
# Bayesians do not use the ML estimate for p. 
# They treat p as a random variable with its own distribution 
# of values. The distribution is defined by existing evidence. 


# We fix the value of data. Pr(data) is the same for all values of p

# Pr(data | p) = 
pr_data_p = binom(10,5)

# We have a prior belief about p. The Prior is Pr(p)
# because its a coin toss we use the beta distribution (we'll special case it as the biniomal)

# data = num_heads, num_tails

# As frequentists we belive: 
# p = num_heads / num_total

# As bayesians we believe: 
# Pr(p|data) = (Pr(data|p) * Pr(p)) / Pr(data)

# We really want to know 
# Pr(data | p)

# Coin flipping is a binomial distribution. 
# The conjugate prior of the binomial distribution is the Beta 

'''
Conjugate priors are analogous to eigenfunctions in operator theory, in that
they are distributions on which the "conditioning operator" acts in a
well-understood way, thinking of the process of changing from the prior to the
posterior as an operator.

However, the processes are only analogous, not identical: conditioning is not linear, as the space of distributions is not closed under linear combination, only convex combination, and the posterior is only of the same form as the prior, not a scalar multiple.

'''


# Pr(p|data) = (Pr(data|p) * Pr(p)) / Pr(data)


# P(data | p) = binom(total, num_heads) * p**(num_heads) * (1-p)**num_tails
# Drop constant
# P(data | p) \propto p**(num_heads) * (1-p)**num_tails
# --
# P(p | data) \propto P(data | p) * Pr(p)
# P(p | data) \propto p**(num_heads) * (1-p)**num_tails * Pr(p)

# now we need to know Pr(p), which we use "prior information" for


# We use a beta prior because it is the conjugate of binomial
# Beta(p; a,b) = Gamma(a+b) / (Gamma(a) * Gamma(b)) * p**(a-1) * (1-p)**(b-1)
# Pr(p) = Beta(p; a,b)


# Using the prior 
# P(p | data) \pt p**(num_heads) * (1-p)**num_tails * Pr(p)
# P(p | data) \pt p**(num_heads) * (1-p)**num_tails * Beta(p; a,b)
# P(p | data) \pt p**(num_heads) * (1-p)**num_tails * Gamma(a+b) / (Gamma(a) * Gamma(b)) * p**(a-1) * (1-p)**(b-1)
# Drop constant
# P(p | data) \pt p**(num_heads) * (1-p)**num_tails * p**(a-1) * (1-p)**(b-1)
# P(p | data) \pt p**(num_heads+a-1) * (1-p)**(num_tails+b-1)
# P(p | data) \pt p**((num_heads+a)-1) * (1-p)**((num_tails+b)-1)

# Because we identify this as a beta distribution we know the normalizing factor
#
# NormFactor = Gamma((num_heads+a)+(num_tails+b)) / (Gamma((num_heads+a)) * Gamma((num_tails+b)))
# 
# P(p | data) = p**(num_heads+a-1) * (1-p)**(num_tails+b-1) *\
#                Gamma((num_heads+a)+(num_tails+b)) /\
#                (Gamma((num_heads+a)) * Gamma((num_tails+b)))
#
#
# Therefore the distribution for p is Beta(p; a+10, b+4)
# We still need to specify prior information: 
# aka setting a and b. 
# We can assume a uniform distribution (special case where a=1, b=1)

# Therefore:
# P(p | data) = Beta(p, 11, 4)

# Ok, inference time:

# P(HH | data) = \int_0^1 Pr(HH | p) * Pr(p | data) dp 

# Two tosses are independent and we do not update our prior

# Term 1:
# Pr(H | p)**2 = p**2
# Term 2 we already solved for

# P(HH | data) = \int_0^1  p**2 * Pr(p | data) dp 

# P(HH | data) = \int_0^1  p**2 * Beta(p, 11, 4) dp 

# P(HH | data) = 1/Z \int_0^1  p**(10+a-1+2) * (1-p)**(4+b-1) dp

# SOLVING THE INTEGRAL ELIMINATES P. WE CONSIDER ALL POSSIBLE P ESSENTIALLY AND
# TAKE THE AREAS WHERE IT ACTUALLY HAS SUPPORT

# P(HH | data) = B(10+a+2, 4+b) / B(10+a, 4+b)


# The beta function is an EUiler Integral 

# B(x,y) = \int_0^1 t^{x-1}(1-t)^(y-1) dt
