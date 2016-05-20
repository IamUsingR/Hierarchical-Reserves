###   Download and process schedule p data (keep only selected insurers)

library(data.table)

setwd("C:/Projects/Reserving Models/Schedule P Data")
ins <- fread('insurers to use.csv')
ca <- fread('http://www.casact.org/research/reserve_data/comauto_pos.csv')
wc <- fread('http://www.casact.org/research/reserve_data/wkcomp_pos.csv')
pa <- fread('http://www.casact.org/research/reserve_data/ppauto_pos.csv')
ol <- fread('http://www.casact.org/research/reserve_data/othliab_pos.csv')

ca[, line := 'CA']
wc[, line := 'WC']
pa[, line := 'PA']
ol[, line := 'OL']

dat <- rbind(ca, wc, pa, ol, use.names = FALSE)

setkey(ins, line, groupcode)
setkey(dat, line, GRCODE)
dat <- dat[ins, .(line, grpcode = GRCODE, w = AccidentYear, d = DevelopmentYear
                  , net_premium = EarnedPremNet_C
                  , dir_premium = EarnedPremDIR_C
                  , ced_premium = EarnedPremCeded_C
                  , cum_pdloss = CumPaidLoss_C
                  , cum_incloss = IncurLoss_C
                  , bulk_loss = BulkLoss_C
                  , single = Single
                  , posted_reserve97 = PostedReserve97_C)]

setkey(dat, line, grpcode, w, d)
dat[, inc_pdloss := cum_pdloss - shift(cum_pdloss, 1L, type = 'lag', fill = 0L)
    , .(line, grpcode, w)]
rm(ca, wc, pa, ol, ins)
write.csv(dat, 'selected insurer data.csv', row.names = FALSE)

