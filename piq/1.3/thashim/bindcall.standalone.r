#!/usr/bin/Rscript
#Rscript script commondir pwmdir tmpdir outdir bamfile pwmid
#example:
#Rscript pertf.r /cluster/thashim/basepiq/common.r /cluster/thashim/tmppiq/ /scratch/tmp/ /cluster/thashim/130130.mm10.d0/ /cluster/thashim/tmppiq/d0.RData 139

options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)

#location of common.r containing runtime parameters
commonfile = args[1]

#directory where pwm matches are stored
pwmdir = args[2]

#directory to use as fast temporary storage
tmpdir = args[3]

#location of output calls
outdir = args[4]

outdir.train = args[5]

#location of the bam RData file made by bam2rdata.r
bamfile = args[6]

#which pwm file to use in pwmdir
pwmid = args[7]

###
# do FW

match.rc = F
dump.chropen = F

two.pass = F
suppressWarnings(source(commonfile))
if(overwrite==F & file.exists( file.path(outdir,paste0(pwmid,'-diag.pdf')))){
  stop(paste0('found previous run for ',pwmid,' avoiding overwrite'))
}

debugstring = c('loading pwm','loadbam','clustering','binding outputs')

dump.bed = T

tryCatch({
phase=0
load(paste0(pwmdir,pwmid,'.pwmout.RData'))
if(sum(clengths[1])>0){
phase=1
at<-Sys.time()
source('/mnt/galaxyTools/tools/piq/1.3/thashim/loadbam.r')
print(Sys.time()-at);at<-Sys.time()

pwname.short = gsub("[[:punct:]]","",pwmname)
if(match.rc){
    pwname.short=paste0(pwname.short,'.RC')
}
load(file.path(outdir.train,paste0(pwmid,'-',pwname.short,'-params.RData')))

phase=3
source('/mnt/galaxyTools/tools/piq/1.3/thashim/bindcall.r')
print(Sys.time()-at);at<-Sys.time()
}
},error = function(e){
   e$message=paste0('error during ',debugstring[phase+1],'\n','Error msg: ',e$message,'\n Args:',paste0(commandArgs(trailingOnly = TRUE),collapse=':'))
   stop(e)
})

###
# do RC

match.rc = T

suppressWarnings(source(commonfile))
if(overwrite==F & file.exists( file.path(outdir,paste0(pwmid,'-diag.rc.pdf')))){
  stop(paste0('found previous run for ',pwmid,' avoiding overwrite'))
}

debugstring = c('loading pwm.rc','loadbam.rc','clustering.rc','binding outputs.rc')

tryCatch({
phase=0
load(paste0(pwmdir,pwmid,'.pwmout.rc.RData'))
if(sum(clengths[1])>0){
phase=1
at<-Sys.time()
source('/mnt/galaxyTools/tools/piq/1.3/thashim/loadbam.r')
print(Sys.time()-at);at<-Sys.time()

pwname.short = gsub("[[:punct:]]","",pwmname)
if(match.rc){
    pwname.short=paste0(pwname.short,'.RC')
}
load(file.path(outdir.train,paste0(pwmid,'-',pwname.short,'-params.RData')))

phase=3
source('/mnt/galaxyTools/tools/piq/1.3/thashim/bindcall.r')
print(Sys.time()-at);at<-Sys.time()
}
},error = function(e){
   e$message=paste0('error during ',debugstring[phase+1],'\n','Error msg: ',e$message,'\n Args:',paste0(commandArgs(trailingOnly = TRUE),collapse=':'))
   stop(e)
})
