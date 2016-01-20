setwd("~/Dropbox/My_Website")
x=seq(-4,4,length=200)
y=dnorm(x,mean=0,sd=1)
png("./images/vis.png",  width = 750, height = 200, units = "px")

par(bg="#2F2F2F")
## 1024 x 195
par(mar=c(1, 0, 0, 0))
plot(x,y,type="l",lwd=1,col="red", xaxt='n', yaxt='n', ylab="", xlab="", axes=FALSE, ylim=c(0, 1.6))
y=dnorm(x,mean=0.25,sd=1)
# points(x,y,type="l",lwd=1,col="blue")
cols <- seq(0.25, 10, length=200)
for (icol in 1:length(cols)){
	y=dnorm(x,mean=0,sd=cols[icol])
	points(x,y,type="l",lwd=1,col=icol)
}
legend(-2.5, 1.5, legend="software", cex=5, text.col ="white", bty="n")

dev.off()
