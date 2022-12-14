rm(list=ls())
library("deSolve"); library("ggplot2"); library("cowplot")

GenTime <- function(T2, R0) {
  G = T2 * ((R0-1)/log(2))
  return(G)
}

#### Baseline Model #### 

SIR <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - beta*S*I
    dI = beta*S*I - mu*I
    dR = mu*I 
    dC = beta*S*I
    return(list(c(dS,dI,dR,dC)))
  })
} 

init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          beta = (2*(1/(GenTime(6,2)))))
outbase <- data.frame(ode(y = init, func = SIR, times = times, parms = parms))
outbase[,6] <- as.numeric(parms[2])


#Plotting
outdata <- rbind(data.frame("Compartment" = "Infec", "Times" = outbase[,1], "Prev" = outbase[,3]),
                 data.frame("Compartment" = "Susc", "Times" = outbase[,1], "Prev" = outbase[,2]),
                 data.frame("Compartment" = "Rec", "Times" = outbase[,1], "Prev" = outbase[,4]),
                 data.frame("Compartment" = "Cumulative", "Times" = outbase[,1], "Prev" = outbase[,5]),
                 data.frame("Compartment" = "Beta", "Times" = outbase[,1], "Prev" = outbase[,6]))

ggplot(data = outdata[outdata$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") +
  scale_y_continuous(limits = c(0,0.2) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

ggplot(data = outdata[outdata$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") +
  scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

ggplot(data = outdata[outdata$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") +
  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

#### SCENARIO 1 - Beta tatic Decrease #### 

betastatdecrease <- function(time, int_timestart, int_timeend) {
  ifelse((time >= int_timestart & time <= int_timeend),
         (2*(1/(GenTime(6,2))))*0.625,
         (2*(1/(GenTime(6,2)))))
}

SIR1 <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - betastatdecrease(time,int_timestart,int_timeend)*S*I
    dI = betastatdecrease(time,int_timestart,int_timeend)*S*I - mu*I
    dR = mu*I 
    dC = betastatdecrease(time,int_timestart,int_timeend)*S*I
    return(list(c(dS,dI,dR, dC)))
  })
}


init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          int_timestart = 41, 
          int_timeend = 41+(12*7))

out1 <- data.frame(ode(y = init, func = SIR1, times = times, parms = parms))
out1$beta <- betastatdecrease(times, as.numeric(parms[2]), as.numeric(parms[3]))

#Plotting 

outdata1 <- rbind(data.frame("Compartment" = "Infec", "Times" = out1[,1], "Prev" = out1[,3]),
                  data.frame("Compartment" = "Susc", "Times" = out1[,1], "Prev" = out1[,2]),
                  data.frame("Compartment" = "Rec", "Times" = out1[,1], "Prev" = out1[,4]),
                  data.frame("Compartment" = "Cumulative", "Times" = out1[,1], "Prev" = out1[,5]),
                  data.frame("Compartment" = "Beta", "Times" = out1[,1], "Prev" = out1[,6]))

p11 <- ggplot(data = outdata1[outdata1$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") + scale_y_continuous(limits = c(0,0.15) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 0.15, fill = "darkred", alpha = .2)

p21 <- ggplot(data = outdata1[outdata1$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") + scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

p31 <- ggplot(data = outdata1[outdata1$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") + scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(), 
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

p41 <- ggplot(data = outdata1[1:903,], aes(x = Times, y = Prev, col = Compartment)) + geom_line(size = 1.05) +
  labs(x ="Time (Days)", y = "Proportion of Population") +  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) + 
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

plot_grid(p11, NULL, p21, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p31, NULL, p21, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p41, NULL, p21, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))

#### SCENARIO 2 - Beta Decrease + Linear Increase #### 

betadecrease <- function(time, int_timestart, int_timeend, betastart, betaend) {
  betalin <- approxfun(x=c(int_timestart, int_timeend),y= c(betastart, betaend), method="linear", rule  =2)
  ifelse((time >= int_timestart & time <= int_timeend),
         betalin(time),
         (2*(1/(GenTime(6,2)))))
}

SIR2 <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    dI = betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I - mu*I
    dR = mu*I 
    dC = betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    return(list(c(dS,dI,dR, dC)))
  })
}

init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          int_timestart = 41, 
          int_timeend = 41+(12*7),
          beta_base = 2*(1/(GenTime(6,2)))*0.25,
          beta_int = 2*(1/(GenTime(6,2))))

out2 <- data.frame(ode(y = init, func = SIR2, times = times, parms = parms))
out2$beta <- betadecrease(times, as.numeric(parms[2]), as.numeric(parms[3]), as.numeric(parms[4]), as.numeric(parms[5]))

#Plotting 

outdata2 <- rbind(data.frame("Compartment" = "Infec", "Times" = out2[,1], "Prev" = out2[,3]),
                  data.frame("Compartment" = "Susc", "Times" = out2[,1], "Prev" = out2[,2]),
                  data.frame("Compartment" = "Rec", "Times" = out2[,1], "Prev" = out2[,4]),
                  data.frame("Compartment" = "Cumulative", "Times" = out2[,1], "Prev" = out2[,5]),
                  data.frame("Compartment" = "Beta", "Times" = out2[,1], "Prev" = out2[,6]))

p12 <- ggplot(data = outdata2[outdata2$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") + scale_y_continuous(limits = c(0,0.15) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 0.15, fill = "darkred", alpha = .2)

p22 <- ggplot(data = outdata2[outdata2$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") + scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

p32 <- ggplot(data = outdata2[outdata2$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") + scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(), 
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

p42 <- ggplot(data = outdata2[1:903,], aes(x = Times, y = Prev, col = Compartment)) + geom_line(size = 1.05) +
  labs(x ="Time (Days)", y = "Proportion of Population") +  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) + 
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

plot_grid(p12, NULL, p22, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p32, NULL, p22, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p42, NULL, p22, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))

#### SCENARIO 3 - Beta Linear Decrease #### 

betadecrease <- function(time, int_timestart, int_timeend, betastart, betaend) {
  betalin <- approxfun(x=c(int_timestart, int_timeend),y= c(betastart, betaend), method="linear", rule  =2)
  ifelse((time >= int_timestart & time <= int_timeend),
         betalin(time),
         (2*(1/(GenTime(6,2)))))
}

SIR3 <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    dI = betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I - mu*I
    dR = mu*I 
    dC = betadecrease(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    return(list(c(dS,dI,dR, dC)))
  })
}

init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          int_timestart = 41, 
          int_timeend = 41+(12*7),
          beta_base = (2*(1/(GenTime(6,2)))),
          beta_int = (2*(1/(GenTime(6,2))))*0.25)

out3 <- data.frame(ode(y = init, func = SIR3, times = times, parms = parms))
out3$beta <- betadecrease(times, as.numeric(parms[2]), as.numeric(parms[3]), as.numeric(parms[4]), as.numeric(parms[5]))

#Plotting 

outdata3 <- rbind(data.frame("Compartment" = "Infec", "Times" = out3[,1], "Prev" = out3[,3]),
                  data.frame("Compartment" = "Susc", "Times" = out3[,1], "Prev" = out3[,2]),
                  data.frame("Compartment" = "Rec", "Times" = out3[,1], "Prev" = out3[,4]),
                  data.frame("Compartment" = "Cumulative", "Times" = out3[,1], "Prev" = out3[,5]),
                  data.frame("Compartment" = "Beta", "Times" = out3[,1], "Prev" = out3[,6]))

p13 <- ggplot(data = outdata3[outdata3$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") + scale_y_continuous(limits = c(0,0.15) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 0.15, fill = "darkred", alpha = .2)

p23 <- ggplot(data = outdata3[outdata3$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") + scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

p33 <- ggplot(data = outdata3[outdata3$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") + scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(), 
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

p43 <- ggplot(data = outdata3[1:903,], aes(x = Times, y = Prev, col = Compartment)) + geom_line(size = 1.05) +
  labs(x ="Time (Days)", y = "Proportion of Population") +  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) + 
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

plot_grid(p13, NULL, p23, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p33, NULL, p23, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p43, NULL, p23, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))

#### SCENARIO 4 - Beta Linear Decrease then Increase #### 

betaincdec <- function(time, int_timestart, int_timeend, betastart, betaend) {
  betadec <- approxfun(x=c(int_timestart, int_timestart+abs((int_timestart-int_timeend)/2)), y= c(betastart, betaend), 
                       method="linear", rule =2)
  betainc <- approxfun(x=c(int_timestart+abs((int_timestart-int_timeend)/2), int_timeend),y= c(betaend, betastart), 
                       method="linear", rule = 2)
  ifelse((time >= int_timestart & time <= int_timeend),
         ifelse((time >= int_timestart & time <=  int_timestart+abs((int_timestart-int_timeend)/2)),
                betadec(time),
                betainc(time)),
         2*(1/(GenTime(6,2))))
}

SIR4 <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - betaincdec(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    dI = betaincdec(time,int_timestart,int_timeend, beta_base, beta_int)*S*I - mu*I
    dR = mu*I 
    dC = betaincdec(time,int_timestart,int_timeend, beta_base, beta_int)*S*I
    return(list(c(dS,dI,dR, dC)))
  })
}


init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          int_timestart = 41, 
          int_timeend = 41+(12*7),
          beta_base = (2*(1/(GenTime(6,2)))),
          beta_int = (2*(1/(GenTime(6,2))))*0.25)

out4 <- data.frame(ode(y = init, func = SIR4, times = times, parms = parms))
out4$beta <- betaincdec(times, as.numeric(parms[2]), as.numeric(parms[3]), as.numeric(parms[4]), as.numeric(parms[5]))

#Plotting 

outdata4 <- rbind(data.frame("Compartment" = "Infec", "Times" = out4[,1], "Prev" = out4[,3]),
                  data.frame("Compartment" = "Susc", "Times" = out4[,1], "Prev" = out4[,2]),
                  data.frame("Compartment" = "Rec", "Times" = out4[,1], "Prev" = out4[,4]),
                  data.frame("Compartment" = "Cumulative", "Times" = out4[,1], "Prev" = out4[,5]),
                  data.frame("Compartment" = "Beta", "Times" = out4[,1], "Prev" = out4[,6]))

p14 <- ggplot(data = outdata4[outdata4$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") + scale_y_continuous(limits = c(0,0.15) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 0.15, fill = "darkred", alpha = .2)

p24 <- ggplot(data = outdata4[outdata4$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") + scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

p34 <- ggplot(data = outdata4[outdata4$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") + scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(), 
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

p44 <- ggplot(data = outdata4[1:903,], aes(x = Times, y = Prev, col = Compartment)) + geom_line(size = 1.05) +
  labs(x ="Time (Days)", y = "Proportion of Population") +  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) + 
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)


plot_grid(p14, NULL, p24, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p34, NULL, p24, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p44, NULL, p24, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))


#### SCENARIO 4 - Beta Pulse #### 

#Beta Function to "Pulse" every other week
betapulse <- function(time) {
  ifelse((time >= 41+7 & time <= 41+21) | (time >= 41+35 & time <= 41+49) | (time >= 41+63 & time <= 41+77), 
         2*(1/(GenTime(6,2)))*0.25, 2*(1/(GenTime(6,2))))
}

SIR5 <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS = - betapulse(time)*S*I
    dI = betapulse(time)*S*I - mu*I
    dR = mu*I 
    dC = betapulse(time)*S*I
    return(list(c(dS,dI,dR, dC)))
  })
}

init <- c(S = 0.9999, I = 0.0001, R = 0, C = 0)
times <- seq(0,300,by = 1)
parms = c(mu = 1/(GenTime(6,2)),
          int_timestart = 41, 
          int_timeend = 41+(12*7),
          beta_base = (2*(1/(GenTime(6,2)))),
          beta_int = (2*(1/(GenTime(6,2))))*0.25)

out5 <- data.frame(ode(y = init, func = SIR5, times = times, parms = parms))
out5$beta <- betapulse(seq(0,300))

#Plotting 

outdata5 <- rbind(data.frame("Compartment" = "Infec", "Times" = out5[,1], "Prev" = out5[,3]),
                  data.frame("Compartment" = "Susc", "Times" = out5[,1], "Prev" = out5[,2]),
                  data.frame("Compartment" = "Rec", "Times" = out5[,1], "Prev" = out5[,4]),
                  data.frame("Compartment" = "Cumulative", "Times" = out5[,1], "Prev" = out5[,5]),
                  data.frame("Compartment" = "Beta", "Times" = out5[,1], "Prev" = out5[,6]))

p15 <- ggplot(data = outdata5[outdata5$Compartment == "Infec",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkblue") +
  labs(x ="Time (Days)", y = "Proportion of Infected Humans") + scale_y_continuous(limits = c(0,0.15) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 0.15, fill = "darkred", alpha = .2)

p25 <- ggplot(data = outdata5[outdata5$Compartment == "Beta",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Beta Parameter") + scale_y_continuous(limits = c(0,0.3) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) 

p35 <- ggplot(data = outdata5[outdata5$Compartment == "Cumulative",], aes(x = Times, y = Prev)) + geom_line(size = 1.05, col = "darkred") +
  labs(x ="Time (Days)", y = "Cumulative Infections") + scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(), 
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) +
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

p45 <- ggplot(data = outdata5[1:903,], aes(x = Times, y = Prev, col = Compartment)) + geom_line(size = 1.05) +
  labs(x ="Time (Days)", y = "Proportion of Population") +  scale_y_continuous(limits = c(0,1) ,  expand = c(0,0)) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.spacing.x = unit(0.3, 'cm'), legend.text=element_text(size=11), plot.margin=unit(c(0.7,0.7,0.8,0.8),"cm")) + 
  scale_x_continuous(expand = c(0, 0)) + annotate("rect", xmin = as.numeric(parms[2]), xmax = as.numeric(parms[3]), ymin = 0, ymax = 1, fill = "darkred", alpha = .2)

plot_grid(p15, NULL, p25, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p35, NULL, p25, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))
plot_grid(p45, NULL, p25, align = "v", nrow = 3, rel_heights = c(2, -0.15, 1))