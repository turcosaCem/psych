#switched from density = 50 to alpha =.5  to speed up the plotting 
"violinBy"  <- function(x,var=NULL,grp=NULL,grp.name=NULL,ylab="Observed",xlab="",main="Density plot",alpha= 1,adjust=1,restrict=TRUE,xlim=NULL,add=FALSE,col=NULL,pch=20,scale=NULL, ...) {
SCALE=.3  #how wide are the plots?

count.valid <- function(x) {sum(!is.na(x)) }
if(missing(col)) {col <- c("blue","red","black","purple","green","yellow")}

  if(!is.null(grp)) { 
    if(!is.data.frame(grp) && !is.list(grp) && (length(grp) < NROW(x))) grp <- x[,grp,drop=FALSE]}

 if(!is.null(var)) {if(missing(ylab) & (length(var) ==1)) {ylab <- var}
          x <- x[,var , drop = FALSE]}
 nvar <- nvarg <- NCOL(x)
 x <- char2numeric(x)
     
 col <- adjustcolor(col,alpha.f =alpha)        
if(!is.null(grp)) {
# if(!is.data.frame(grp) && !is.list(grp) && (length(grp) < NROW(x))) grp <- x[,grp]	
 Qnt <-  apply(x,2,function(xx) by(xx,grp,quantile,prob=c(0,1,.5,.25,.75),na.rm=TRUE))
meanX <- apply(x,2,function(xx) by(xx,grp,mean,na.rm=TRUE))
nX <- apply(x,2,function(xx) by(xx,grp,count.valid))
meanX <- matrix(unlist(meanX))
   Qnt <- matrix(unlist(Qnt),nrow=5)
   ngrp <- ncol(Qnt)/nvar
   nvarg <- ncol(Qnt)
   rangex <- matrix(c(Qnt[1,],Qnt[2,]),nrow=2,byrow=TRUE)
} else {Qnt <- apply(x,2,quantile,prob=c(0,1,.5,.25,.75),na.rm=TRUE)
meanX <- apply(x,2,mean,na.rm=TRUE)}
minx <- Qnt[1,]
maxx <- Qnt[2,]
medx <- Qnt[3,]
Q25 <-  Qnt[4,]
Q75 <-  Qnt[5,]
#rangex <- apply(x,2,range,na.rm=TRUE)
rangex <- matrix(c(Qnt[1,],Qnt[2,]),nrow=2,byrow=TRUE)
names <- colnames(x)
tot.n.obs <- nrow(x)

if(!is.null(grp)) {
if(missing(grp.name)) grp.name <- 1:ngrp
if(length(names) > 1 ) {names <- paste(rep(names,each=ngrp),grp.name[1:ngrp],sep=" ")} else {names <- grp.name}

     col <- rep(col,nvar* ngrp)}
d <- list(nvar)
if(missing(xlim)) xlim <- c(.5,nvarg+.5)

for (i in 1:nvar) {
#if(!is.null(grp)) { if(restrict) {d[[i]] <- by(x[,i], grp ,function(xx) density(xx,na.rm=TRUE,from=rangex[1,i],to=rangex[2,i]))}
if(!is.null(grp)) { if(restrict) {d[[i]] <- by(x[,i], grp ,function(xx) density(xx,na.rm=TRUE,adjust=adjust,from=min(xx,na.rm=TRUE),to=max(xx,na.rm=TRUE)))} else {
d[[i]] <- by(x[,i], grp ,function(xx) density(xx,na.rm=TRUE)) }} else {
if(restrict) {d[[i]] <- density(x[,i],na.rm=TRUE,adjust=adjust,from=minx[i],to=maxx[i])} else {
d[[i]] <- density(x[,i],na.rm=TRUE)} }
}

if(!add) {plot(meanX,ylim=c(min(minx),max(maxx)),xlim=xlim,axes=FALSE,xlab=xlab,ylab=ylab,main=main,pch=pch,...)
  axis(1,1:nvarg,names,...)
  axis(2,...)
  box()}
if(!is.null(grp)) d <- unlist(d,recursive=FALSE)
rev <- (length(d[[1]]$y):1) #this prevents a line down the middle
for(i in 1:nvarg) {
if(!is.null(scale)) {width <- scale*sqrt(nX[[i]]/tot.n.obs)/max(d[[i]]$y)} else {width <- SCALE/max(d[[i]]$y)}
#polygon(width*c(-d[[i]]$y,d[[i]]$y[rev])+i,c(d[[i]]$x,d[[i]]$x[rev]),density=density,col=col[i],...)
polygon(width*c(-d[[i]]$y,d[[i]]$y[rev])+i,c(d[[i]]$x,d[[i]]$x[rev]),col=col[i],...)
dmd <- max(which(d[[i]]$x <= medx[i]))
d25 <- max(which(d[[i]]$x <= Q25[i]))
d75 <- max(which(d[[i]]$x <= Q75[i]))
segments(x0=width*d[[i]]$y[dmd] +i ,y0=d[[i]]$x[dmd],x1=-width*d[[i]]$y[dmd]+i,y1=d[[i]]$x[dmd],lwd=2)
segments(x0=width*d[[i]]$y[d25] +i ,y0=d[[i]]$x[d25],x1=-width*d[[i]]$y[d25]+i,y1=d[[i]]$x[d25])
segments(x0=width*d[[i]]$y[d75] +i ,y0=d[[i]]$x[d75],x1=-width*d[[i]]$y[d75]+i,y1=d[[i]]$x[d75])
}
 
 }
#created March 10, 2014 following a discussion of the advantage of showing distributional values
#modified March 22, 2014 to add the grouping variable
#basically just a violin plot.
#modified December, 2016 to allow for scaling of the widths of the plots by sample size. 


"histBy" <- function(x,grp=NULL,restrict=TRUE,xlim=NULL,ylab="Observed",xlab="",main="Density plot",density=20,scale=TRUE,col= c("blue","red"),...) {
count.valid <- function(x) {sum(!is.na(x)) }
if(missing(col)) {col <- c("blue","red")}
if(restrict) {minx <- min(x)
   maxx <- max(x)}
x <- as.matrix(x,drop=FALSE)
meanX <- apply(x,2,mean,na.rm=TRUE)
nX <- apply(x,2,function(xx) by(xx,grp,count.valid))

if(!is.null(grp)) { if(restrict) {d <- by(x[,1], grp ,function(xx) density(xx,na.rm=TRUE,from=min(xx,na.rm=TRUE),to=max(xx,na.rm=TRUE)))} else {
d <- by(x[,1], grp ,function(xx) density(xx,na.rm=TRUE)) }} else {
if(restrict) {d <- density(x[,1],na.rm=TRUE,from=minx,to=maxx)} else {
d <- density(x[,1],na.rm=TRUE)} }
d <- unlist(d,recursive=FALSE)
maxy <- max(d[[1]]$y,d[[2]]$y,na.rm=TRUE)
plot(NA,ylim=c(0,maxy),xlim=xlim,axes=FALSE,xlab=xlab,ylab=ylab,main=main,pch=pch,...)
  axis(1,1:nvarg,names,...)
  axis(2,...)
  box()
if(!is.null(scale)) {width <- scale*sqrt(nX[[i]]/tot.n.obs)/max(d[[i]]$y)} else {width <- SCALE/max(d[[i]]$y)}
polygon(width*c(-d[[i]]$x,d[[i]]$x[rev])+i,c(d[[i]]$y,d[[i]]$y[rev]),density=density,col=col[i],...)
}


#11/28/17

 "densityBy" <- function(x,var=NULL,grp=NULL,freq=FALSE,col=c("blue","red","black"),alpha=.5,adjust=1,xlab="Variable", ylab="Density",main="Density Plot") {
if(!is.null(var)) x <- x[,c(var,grp),drop=FALSE]
 x <- char2numeric(x)
 col <- adjustcolor(col,alpha.f =alpha)
 if(missing(main) && freq) main="Frequency Plot"
 if(missing(ylab) && freq) ylab <- "N * density"
 if(missing(xlab) && (length(var) ==1)) xlab <- var
 if(!is.null(grp)) { 
    if(!is.data.frame(grp) && !is.list(grp) && (length(grp) < NROW(x))) grp <- x[,grp,drop=FALSE]
   d <- by(x[,var],grp,function(xx) density(xx, adjust=adjust,na.rm=TRUE))
   maxiy <- rep(NA,length(d))
   for(i in 1:length(d) ) {if(freq){ maxiy[i] <- max(d[[i]]$n *d[[i]]$y)} else { 
                   maxiy[i] <- max(d[[i]]$y)}
                   }
   maxy <- max(maxiy)
   
   plot(d[[1]],ylim=c(0,maxy),main=main,ylab=ylab,xlab=xlab ) 
   
   for (i in 1:length(d)) {
   if(freq) {scal <- d[[i]]$n
      d[[i]]$y <- d[[i]]$y*scal} 
   polygon(d[[i]] ,col=col[i])
   }
 } else {
 d <- density(x[,var],na.rm=TRUE,adjust=adjust)
   plot(d,main=main,ylab=ylab,xlab=xlab )
    polygon(d,col=col[1])
 } }