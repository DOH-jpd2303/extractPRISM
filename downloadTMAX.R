# Load libraries
library(jsonlite)
library(rvest)
library(raster)
library(rgdal)
library(geodata)
library(rasterVis)
library(sp)
library(tidyverse)

# Load configuration settings
config <- jsonlite::read_json('C:/Jon/cfig/extractPRISM.json')
tmax_dir <- paste0(config$dirPRISM, 'BILS/TMAX/')


# DOWNLOAD FILES ----------------------------------------------------------
# List all of the PRISM files on an FTP site
listPRISMFiles <- function(var, year){
  var <- tolower(var)
  lnk <- glue::glue("https://ftp.prism.oregonstate.edu/daily/{var}/{year}")
  ftp_txt <- read_html(lnk)
  ftp_files <- html_attr(html_nodes(ftp_txt, 'a'), 'href')
  ftp_files <- ftp_files[grepl('PRISM', ftp_files)]
  return(list(lnk = lnk, files = ftp_files))
}

# Get TMAX files for 2010
files <- listPRISMFiles(var = 'tmax', year = '2010')
files <- lapply(2011:2021, listPRISMFiles, var = 'tmax')
names(files) <- 2011:2021

# Function to download all of the files
dlPRISMDaily <- function(baselnk, file, outdir){
  fn <- paste0(baselnk, '/', file)
  download.file(fn, destfile = paste0(outdir, file))
}

for(i in(1:length(files))){
  dir <- paste0(tmax_dir, names(files)[[i]], '/')
  dir.create(dir)
  dlPRISMDaily(files[[i]]$lnk, files[[i]]$files, outdir = dir)
}


dirs <- paste0(tmax_dir, names(files), '/')
for(d in dirs){
  fns <- list.files(d)
  fn <- paste0(d, '/', fns)
  lapply(fn, function(x) unzip(x, exdir = paste0(d, '/', gsub(".zip", '', basename(x)))))
}




# Load configuration settings
config <- jsonlite::read_json('C:/Jon/cfig/extractPRISM.json')
dir2010 <- paste0(config$dirPRISM, 'BILS/TMAX/2010')

fns <- list.files(dir2010)
fn <- paste0(dir2010, '/', fns)
lapply(fn, function(x) unzip(x, exdir = paste0(dir2010, '/', gsub(".zip", '', basename(x)))))