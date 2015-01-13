#' GUI for running LandsatLinkr
#'
#' GUI for running LandsatLinkr
#' @export

run_landsatlinkr = function(){
  
  choices = c("Prepare MSS",
              "Prepare TM/ETM+",
              "Calibrate MSS to TM/ETM+",
              "Composite imagery")
  
  selection = select.list(choices, title = "Select a process to run")
  if(selection == "Prepare MSS"){process = seq(1:5)}
  if(selection == "Prepare TM/ETM+"){process = 6}
  if(selection == "Calibrate MSS to TM/ETM+"){process = 7}
  if(selection == "Composite imagery"){process = 8}
  
  
  choices = c("No", "Yes")
  selection = select.list(choices, title = "Process in parallel using 2 cores when possible?")
  if(selection == "No"){cores = 1}
  if(selection == "Yes"){cores = 2}
  
  if(sum(process %in% seq(1,6)) > 0){
    scenedir = choose.dir(caption = "Select an MSS or TM/ETM+ scene directory. ex. 'C:/mss/036032'")
    reso = 60 #set default
    proj = "albers" #set default
    if(sum(process %in% c(1,6)) > 0){
      choices = c("30 meter", "60 meter")
      selection = select.list(choices, title = "Select a pixel resolution to use")
      if(selection == "30 meter"){reso = 30}
      if(selection == "60 meter"){reso = 60}
      
      choices = c("Native NAD83 UTM", "USGS North American Albers")
      selection = select.list(choices, title = "Select a map projection to use")
      if(selection == "Native NAD83 UTM"){proj = "default"}
      if(selection == "USGS North American Albers"){proj = "albers"}
    }
    
    demfile=NULL
    if(all(is.na(match(process,5))) == F){
      demfile = choose.files(caption = "Select a scene corresponding DEM file", multi=F)
    }
    #return(list(scenedir, demfile, proj, reso, process,cores))
    prepare_images(scenedir, demfile, proj=proj, reso=reso, process=process,cores=cores)
  }
  
  ################################
  #msscal and mixel
  if(sum(process %in% c(7,8)) > 0){
    if(sum(process %in% 7) > 0){
      msswrs1dir = choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'")
      msswrs2dir = choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'")
      tmwrs2dir = choose.dir(caption = "Select a TM WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'")
      outdir=NULL
      index=NULL
      runname=NULL  
    }
    
    
    if(sum(process %in% 8) > 0){
      choices = c("Yes", "No")
      msswrs1dir = choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'")
      answer = "Yes"
      while(answer == "Yes"){
        answer = select.list(choices, title = "Is there another MSS WRS-1 scene directory to add?")
        if(answer == "Yes"){msswrs1dir = c(msswrs1dir, choose.dir(caption = "Select a MSS WRS-1 scene directory. ex. 'C:/mss/wrs1/036032'"))}
      }
      
      msswrs2dir = choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'")
      answer = "Yes"
      while(answer == "Yes"){
        answer = select.list(choices, title = "Is there another MSS WRS-2 scene directory to add?")
        if(answer == "Yes"){msswrs2dir = c(msswrs2dir, choose.dir(caption = "Select a MSS WRS-2 scene directory. ex. 'C:/mss/wrs2/034032'"))}
      }
      
      tmwrs2dir = choose.dir(caption = "Select a TM WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'")
      answer = "Yes"
      while(answer == "Yes"){
        answer = select.list(choices, title = "Is there another TM WRS-2 scene directory to add?")
        if(answer == "Yes"){tmwrs2dir = c(tmwrs2dir, choose.dir(caption = "Select a TM WRS-2 scene directory. ex. 'C:/tm/wrs2/034032'"))}
        
        
        outdir = choose.dir(caption = "Select a directory to write the outputs to. ex. 'C:/composites/wrs2_034032'")
        
        choices = c("Tasseled cap angle",
                    "Tasseled cap brightness",
                    "Tasseled cap greenness",
                    "Tasseled cap wetness")
        selection = select.list(choices, title = "Select an index to create composites for")
        if(selection == "Tasseled cap angle"){index = "tca"}
        if(selection == "Tasseled cap brightness"){index = "tcb"}
        if(selection == "Tasseled cap greenness"){index = "tcg"}
        if(selection == "Tasseled cap wetness"){index = "tcw"}
        
        runname = readline("Provide a unique name for the composite series. ex. project1: ")
        
        choices = c("From file")
        selection = select.list(choices, title = "What area do you want to create composites for?")
        if(selection == "From file"){useareafile = choose.files(caption = "Select a 'usearea' file", multi=F)}
      }
    }
    if(sum((process %in% 7) > 0)){process[1] = 1}
    if(sum((process %in% 8) > 0)){process[process==8] = 2}
    #return(msswrs1dir,msswrs2dir,tmwrs2dir,index,outdir,runname,useareafile,cores,process)
    calibrate_and_composite(msswrs1dir,msswrs2dir,tmwrs2dir,index,outdir,runname,useareafile,doyears="all",order="sensor_and_doy",overlap="mean", cores=cores, process=process)
  } 
}