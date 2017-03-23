library("optimalCaptureSegmentation")

args<-commandArgs(TRUE)

testDOC <- args[1]
controlDOC <- args[2]
kMax <- as.integer(args[3])
minExons <- as.integer(args[4])
minCov <- as.integer(args[5])
plotChr <- args[6]
outNamePlot <- args[7]
outNameList <- args[8]
change <- 0.1
if (plotChr != "all" && plotChr != "autosomes") {
        cytoBandTXT <- args[9]
        if (cytoBandTXT == "FALSE") stop('No CytoBands file specified!')
        cytoBandChrs <- scan(pipe(paste("cut -f 1 ",cytoBandTXT,sep="")),what=" ")
        cytoBandStarts <- scan(pipe(paste("cut -f 2 ",cytoBandTXT,sep="")))
        cytoBandStops <- scan(pipe(paste("cut -f 3 ",cytoBandTXT,sep="")))
        cytoBandIDs <- scan(pipe(paste("cut -f 4 ",cytoBandTXT,sep="")),what=" ")
        cytoBandStains <- scan(pipe(paste("cut -f 5 ",cytoBandTXT,sep="")),what=" ")
} else {
        cytoBandTXT <- ""
}


#mean coverage of each exon in test sample
test <- scan(pipe(paste("cut -f 3 ",testDOC,sep="")),skip=1)
#mean coverage of each exon in control sample
control <- scan(pipe(paste("cut -f 3 ",controlDOC,sep="")),skip=1)
#exon positions
exons <- scan(pipe(paste("cut -f 1 ",testDOC,sep="")),what=" ",skip=1)

#initialize first variables
if (plotChr == "all" || plotChr == "autosomes") {
        chr <- "chr1"
        bpstart <- strsplit(exons[1],"-")[[1]][1]
} else {
        chr <- paste("chr",plotChr,sep="")
        firstBand <- match(chr, cytoBandChrs)
        lastBand <- length(cytoBandChrs)-match(chr,rev(cytoBandChrs))+1
        bpstart <- ""
}


chrbreak = 1
split <- c()
tcovs <- c()
ccovs <- c()
widths <- c()
xlabels <- c()
xlabpos <- c()
alphas <- c()
max <- c()
segmentations <- c()
quot <- sum(test)/sum(control)
plotName <- ""
bppos <- c(paste("#position","exon_count","ratio",sep="\t"))
bpstop <- c()
firstExon <- 0
lastExon <- 0
allBases <- c()


for (i in 1:length(test)) {
        split = strsplit(exons[i],":")[[1]]

        if (plotChr != "all" && plotChr != "autosomes") {
                if (split[1] != chr) {
                        next
                } else  {
                        xlabels <- append(xlabels, strsplit(exons[i],":")[[1]][2])
                        if (bpstart == "") { # write bpstart only ONCE (if on correct chromosome!)
                                bpstart <- strsplit(exons[i],"-")[[1]][1]
                                firstExon <- i
                        }
                }
        }

        if (split[1] == chr) { #staying on the same chromosome
                if (test[i] >= minCov || control[i] >= minCov) {
                        tcovs <- append(tcovs,test[i])
                        ccovs <- append(ccovs,round(control[i]*quot,2))
                } else {
                        tcovs <- append(tcovs, round(mean(test),2))
                        ccovs <- append(ccovs, round(mean(control*quot),2))
                }
        } else { # new chromosome reached
                if (length((strsplit(chr,"_"))[[1]]) == 1) {
                        if(plotChr == "autosomes") {
                                if (chr == "chrX" || chr == "chrY") {
#print("Skipping chrX...")
                                        break
                                }
                        }
#                        print(paste("Processing",chr,"...",sep=" "))
                        k <- min(kMax,length(tcovs))
                        seg <- findOptimalSegmentations(tcovs,ccovs,k)
                        if ((length(seg) > 1) && (!is.nan(seg[1][[1]]$modifiedBIC))) {
                                max <- seg[[which.max(sapply(seg, function (sol) sol$modifiedBIC))]]
                        } else {
                                max <- seg[[1]]
#                               print(paste("*****modifiedBIC = NaN (",k,")*****",sep=""))
                        }
                        segmentations <- append(segmentations,max)
                        start <- 0
                        for (k in 1:max$k) {
                                stop = max$segmentation[k]
                                widths <- append(widths,(stop-start))
                                if (max$alphaEstimated[k] == 0) {
                                        alphas <- append(alphas, 1)
#                                       print(paste("*****alphaEstimated = 0.0 (",k,")*****",sep=""))
                                } else {
                                        alphas <- append(alphas, max$alphaEstimated[k])
                                }
                                start = stop
                        }
                        if (plotChr == "all" || plotChr == "autosomes") {
                                xlabpos <- append(xlabpos,chrbreak)
                                chrbreak <- chrbreak+max$segmentation[max$k]
                                xlabels <- append(xlabels,chr)
                        }
                }
                chr = split[1]
                tcovs <- test[i]
                ccovs <- control[i]
        }
}

#process last chromosome...
if (length((strsplit(chr,"_"))[[1]]) == 1) {
        if(!(plotChr == "autosomes" && chr == "chrX") && !(plotChr == "autosomes" && chr == "chrY")) {
#       print(paste("Processing",chr,"...",sep=" "))
        k <- min(kMax,length(tcovs))
        seg <- findOptimalSegmentations(tcovs,ccovs,k)
        if ((length(seg) > 1) && (!is.nan(seg[1][[1]]$modifiedBIC))) {
                max <- seg[[which.max(sapply(seg, function (sol) sol$modifiedBIC))]]
        } else {
                max <- seg[[1]]
#                       print(paste("*****modifiedBIC = NaN (",k,")*****",sep=""))
        }
        segmentations <- append(segmentations,max)
        start <- 0
        for (k in 1:max$k) {
                stop = max$segmentation[k]
                widths <- append(widths,(stop-start))
                if (max$alphaEstimated[k] == 0) {
                        alphas <- append(alphas, 1)
#                               print(paste("*****alphaEstimated = 0.0 (",k,")*****",sep=""))
                } else {
                        alphas <- append(alphas, max$alphaEstimated[k])
                }
                start = stop
        }
        if (plotChr == "all" || plotChr == "autosomes") {
                xlabpos <- append(xlabpos,chrbreak)
                chrbreak <- chrbreak+max$segmentation[max$k]
                xlabels <- append(xlabels,chr)
        }
        }
}

if (plotChr != "all" && plotChr != "autosomes") {
        xlabels <- c(strsplit(xlabels[1],"-")[[1]][1],strsplit(xlabels[length(xlabels)],"-")[[1]][2])
}


alphasMin <- c()
for (i in 1:length(widths)) {
        if (widths[i] >= minExons) {
                alphasMin <- append(alphasMin, alphas[i])
                bpstop = strsplit(exons[firstExon+sum(widths[1:i])-1],"-")[[1]][2]
                bppos <- append(bppos, paste(paste(bpstart,bpstop,sep="-"),widths[i],alphas[i],sep="\t"))
                bpstart <- strsplit(exons[firstExon+sum(widths[1:i])],"-")[[1]][1]
        }
}

lastExon = firstExon+sum(widths)-1

write(bppos, file = outNameList, append = FALSE)

widths <- ifelse(widths >= minExons, widths, 0)

repalphas <- rep(alphas, widths)

zero <- c()
low <- c()
mid <- c()
high <- c()
k = 1
quot = median(repalphas)


for (i in 1:length(widths)) {
        if (widths[i] != 0) {
        a <- alphas[i]/quot
        end <- sum(widths[1:i])
        if (a < quot-change) {
                for (j in k:end) {
                        if (widths[i] >= minExons) {
                                low <- rbind(low, c(j, a))
                        } else {
                                zero <- rbind(zero, c(j, a))
                        }
                }
        } else if (a > quot+change) {
                for (j in k:end) {
                        if (widths[i] >= minExons) {
                                high <- rbind(high, c(j, a))
                        } else {
                                zero <- rbind(zero, c(j, a))
                        }
                }
        } else {
                for (j in k:end) {
                        if (widths[i] >= minExons) {
                                mid <- rbind(mid, c(j, a))
                        } else {
                                zero <- rbind(zero, c(j, a))
                        }
                }
        }
        k = end + 1
        }
}

all <- rbind(zero,low,mid,high)

upper = round((max(max(all[,2]), 2))*10)/10
lower = round((min(min(all[,2]), 0) - 0.1)*10)/10

if (plotChr == "all" || plotChr == "autosomes") {
        name = ""
} else  {
        name = paste("Chromosome",plotChr,sep=" ")
}

if (plotChr != "all" && plotChr != "autosomes") {

        allBases <- c()
        rep <- c()
        maxAlt <- rep(NA,round(max(all[,2])*1000))
        minAlt <- rep(NA,round(max(all[,2])*1000))
        median <- median(all[c((length(all)/2+1):(length(all)))],na.rm=TRUE)

        for (w in widths) {
                rep = append(rep, rep(w,w))
        }
        for (i in c(1:max(all[,1]))) {
                exon = all[i]
                if (rep[exon] < minExons) {
                        next
                }
                ratio = all[i+length(all)/2]
                range = strsplit(exons[exon+firstExon-1],":")[[1]][2]
                if (length(strsplit(range,"-")[[1]]) > 1) {
                        start = round(as.integer(strsplit(range,"-")[[1]][1])/100000)
                        stop = round(as.integer(strsplit(range,"-")[[1]][2])/100000)
                } else {
                        start = round(as.integer(range)/100000)
                        stop = round(as.integer(range)/100000)
                }
                if (ratio < median-change || ratio > median+change) {
                        if (is.na(minAlt[round(ratio*1000)])) {# set minAlt only once per ratio
                                minAlt[round(ratio*1000)] <- start
                        }
                        maxAlt[round(ratio*1000)] <- stop
                }
                for (p in c(start:stop)) {
                        if (is.null(allBases)) {
                                allBases <- rbind(allBases, c(p, ratio))
                        } else if (is.na(match(p,allBases)) || !allBases[match(p,allBases),2]==ratio) {
                                allBases <- rbind(allBases, c(p, ratio))
                        }
                }
        }
        maxAlt <- unique(maxAlt)[2:length(unique(maxAlt))]
        minAlt <- unique(minAlt)[2:length(unique(minAlt))]
        ratiosByHundredK <- rep(NA,round(cytoBandStops[lastBand]/100000))

        for (a in c(1:sum(widths))) {
                range = strsplit(exons[a+firstExon-1],":")[[1]][2]
                chr = strsplit(exons[a+firstExon-1],":")[[1]][1]
                ratio = all[match(a,all)+sum(widths)]
                if (length(strsplit(range,"-")[[1]]) > 1) {
                        start = round(as.integer(strsplit(range,"-")[[1]][1])/100000)
                        stop = round(as.integer(strsplit(range,"-")[[1]][2])/100000)
                } else {
                        start = round(as.integer(range)/100000)
                        stop = round(as.integer(range)/100000)
                }
                for (p in c(start:stop)) {
                        max <- max(ratio, ratiosByHundredK[p], na.rm=TRUE)
                        min <- min(ratio, ratiosByHundredK[p], na.rm=TRUE)
                        if (max > median+0.15) { #possible amplification, use higher ratio
                                ratiosByHundredK[p] = max
                        } else if (min < median-0.15) { #possible deletion, use lower ratio
                                ratiosByHundredK[p] = min
                        } else {
                                ratiosByHundredK[p] = ratio
                        }
                }
        }

        xpos <- c()
        ypos <- c()
        for (i in c(1:length(ratiosByHundredK))) {
                if (!is.na(ratiosByHundredK[i])) {
                        xpos <- append(xpos, i)
                        ypos <- append(ypos, ratiosByHundredK[i])
                }
        }

        adjust = ((upper-lower))/30
        last <- round(cytoBandStops[lastBand]/100000)

        ## used to plot to PDF
        pdf(file=outNamePlot,width=12,height=8)

        par(mar=c(5,5,3,5))
        plot(1,type="n",ylab="",xlab="",xaxt="n",yaxt="n",xlim=c(0,last),ylim=c(lower-0.1,upper),main="",bty="n",)
        mtext(name,side=1,line=1)
        mtext("Ratio",side=2,at=1.0,line=3)
        axis(2,at=c(lower+0.1,upper),labels=FALSE,lwd=1.5)
        axis(2,at=c((lower+0.1),0.5,1.0,1.5,upper),labels=TRUE,lwd=1.5)
        abline(h=lower+0.1,lwd=1.5)
        lines(xpos,ypos,col="darkgrey")
        points(ratiosByHundredK,col="darkblue",pch=20,cex=1)
        maxID <- rep("",length(maxAlt))
        minID <- rep("",length(minAlt))


        for (b in c(firstBand:lastBand)) {

                st = cytoBandStains[b]
                bands = c((cytoBandStarts[b]/100000):(cytoBandStops[b]/100000))

                for (i in c(1:length(maxAlt))) {
                        if ((maxAlt[i] >= bands[1]) && (maxAlt[i] <= bands[length(bands)])) {
                                maxID[i] = cytoBandIDs[b]
                        }
                }
                for (i in c(1:length(minAlt))) {
                        if ((minAlt[i] >= bands[1]) && (minAlt[i] <= bands[length(bands)])) {
                                minID[i] = cytoBandIDs[b]
                        }
                }

                if (st == "gneg") {
                        next
                } else if (st == "gpos25") {
                        col="gray80"
                        lty = 1
                } else if (st == "gpos50") {
                        col="gray60"
                        lty = 1
                } else if (st == "gpos75") {
                        col="gray30"
                        lty = 1
                } else if (st == "gpos100") {
                        col="gray0"
                        lty = 1
                } else if (st == "gvar") {
                        col="gray20"
                        lty = 1
                        bands = unique(round(bands/10)*10)
                } else if (st == "stalk") {
                        col="gray20"
                        lty = 2
                        bands = unique(round(bands/10)*10)
                } else if (st == "acen") {
                        if (substr(cytoBandIDs[b],0,1)=="p") { #p-arm of chromosome
                                acenStart = cytoBandStarts[b]/100000
                        } else if (substr(cytoBandIDs[b],0,1)=="q") { #q-arm of chromosome
                                acenStop = cytoBandStops[b]/100000
                        }
                        next
                }


                for (p in bands) {

                        lines(c(p,p),c(lower-adjust,lower+adjust),col=col,lty=lty)

                }

        }

        for (i in c(1:length(maxAlt))) {
                if (minID[i] != maxID[i]) {
                        text(c(minAlt[i],maxAlt[i]),y=lower-2*adjust,labels=c(minID[i],maxID[i]),srt=20,col="black",xpd=TRUE,adj=1,cex=0.8)
                } else {
                        text(round(mean(minAlt[i],maxAlt[i])),y=lower-2*adjust,labels=minID[i],srt=20,col="black",xpd=TRUE,adj=1,cex=0.8)
                }
        }

        lines(rbind(c(0,lower-adjust),c(acenStart,lower-adjust)),col="black",lwd=1.5)
        lines(rbind(c(acenStop,lower-adjust),c(last,lower-adjust)),col="black",lwd=1.5)
        lines(rbind(c(0,lower+adjust),c(acenStart,lower+adjust)),col="black",lwd=1.5)
        lines(rbind(c(acenStop,lower+adjust),c(last,lower+adjust)),col="black",lwd=1.5)

        lines(rbind(c(acenStart,lower-adjust),c(acenStop,lower+adjust)),col="black",lwd=2)
        lines(rbind(c(acenStart,lower+adjust),c(acenStop,lower-adjust)),col="black",lwd=2)

        lines(rbind(c(0,lower-adjust),c(0,lower+adjust)),col="black",lwd=1.5)
        lines(rbind(c(last,lower-adjust),c(last,lower+adjust)),col="black",lwd=1.5)


} else {


        ## used to plot to PDF
        pdf(file=outNamePlot, height = 8, width = 12)

        plot(all,type="n",xlim=c(0,chrbreak),ylab="Ratio",xlab="Position",xaxt="n",ylim=c(lower+0.1,upper),main="")
        axis(1, labels=FALSE, at=xlabpos,lwd=1.5)
        axis(2,at=c(lower+0.1,upper),labels=FALSE,lwd=1.5)
        text(xlabpos,par("usr")[3] - 0.1, srt=60, adj=1,labels=xlabels,xpd=TRUE,col.axis="black",las=2)

        xlabpos <- append(xlabpos,chrbreak) #add pos for last vertical line at end of last chromosome

        for (x in xlabpos) {
                abline(v=x,col="lightgray",lty=3,lwd=2)
        }

        lines(all[order(all[,1]),],col="darkgrey")
        points(all,col="darkblue",pch=20,cex=0.5)

}

abline(h=mean(2),col=3,lty=2,lwd=2)
abline(h=mean(0.5),col=2,lty=2,lwd=2)
abline(h=mean(1.5),col=3,lty=3,lwd=2)

graphics.off()

