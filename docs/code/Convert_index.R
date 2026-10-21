# rm(list=ls())

convert_index <- function(infile="index_original.html", outfile = "index.html"){
	trim <- function (x) gsub("^\\s+|\\s+$", "", x)
	
	ff <- file(infile)
	
	dat <- readLines(ff)
	close(ff)
	where.scene <- which(dat == "        r0 = new X.renderer('r0');")
	
	dat[where.scene] <- "        renderer0 = new X.renderer3D();"
	dat[where.scene+1] <- "        renderer0.container = 'r0';"
	dat[where.scene+2] <- "        renderer0.init();"        
	        
	dat <- sub(x=dat, pattern="http://get.goXTK.com/xtk.js", replacement = "http://get.goXTK.com/xtk_edge.js", fixed=TRUE)        
	dat <- gsub(x=dat, pattern=" r0.", replacement = " renderer0.", fixed=TRUE)
	
	### () denotes what you want to match
	dat <- gsub(x=dat, pattern="\\.setColor\\((.*)\\)", replacement = "\\.color = \\[\\1\\]")
	dat <- gsub(x=dat, pattern="\\.setUp\\((.*)\\)", replacement = "\\.up = \\[\\1\\]")
	dat <- gsub(x=dat, pattern="\\.setPosition\\((.*)\\)", replacement = "\\.position = \\[\\1\\]")
	dat <- gsub(x=dat, pattern="\\.setOpacity\\((.*)\\)", replacement = "\\.opacity = \\1")
	dat <- gsub(x=dat, pattern="\\.load\\((.*)\\)", replacement = "\\.file = \\1")
	dat <- gsub(x=dat, pattern="\\.setVisible\\((.*)\\)", replacement = "\\.visible = \\1")
	dat <- gsub(x=dat, pattern="\\.setCaption\\((.*)\\)", replacement = "\\.caption = \\1")
	
	### making models meshes
	dat <- gsub(x=dat, pattern="vtkMRMLModelNode(.*) = new X\\.object\\(\\);", replacement = "vtkMRMLModelNode\\1 = new X\\.mesh\\(\\);")
	
	dat <- gsub(x=dat, pattern=".children().push", replacement = ".children.push", fixed=TRUE)
	dat <- gsub(x=dat, pattern=".camera()", replacement = ".camera", fixed=TRUE)
	
	# parents <- dat[grepl(x=dat, pattern=".children.push", fixed=TRUE)]
	
	# parents <- unique(trim(gsub(x=parents, pattern=".(.*)\\.children\\.push.*", replacement = "\\1", fixed=FALSE)))
	# parents <- parents[parents != "scene"]
	# for(iparent in 1:length(parents)){
		# dat <- gsub(x=dat, pattern=paste(parents[iparent], ".children.push", sep=""), replacement = "scene.children.push", fixed=TRUE)
	# }
	#children.push(vtkMRMLModelNode	
	
	#outfile <- file.path(moddir, "index.html")
	
	ff <- file(outfile)
	writeLines(dat, con=ff)
	close(ff)
}
