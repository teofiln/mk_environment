# read the data and make data frames
# read the tables
tmp <- read.csv("./precipitation2013/Precipitation2013.csv", header=TRUE)
prec13 <- data.frame(tmp[,2:14])
rownames(prec13) <- tmp[,1]

tmp <- read.csv("./precipitation2013/Precipitation2008-2012.csv", header=TRUE)
prec08 <- data.frame(tmp[,2:14])
rownames(prec08) <- tmp[,1]

tmp <- read.csv("./humidity2013/humidity2013.csv", header=TRUE)
humid13 <- data.frame(tmp[,2:13])
rownames(humid13) <- tmp[,1]

tmp <- read.csv("./humidity2013/humidity2008-2012.csv", header=TRUE)
humid08 <- data.frame(tmp[,2:13])
rownames(humid08) <- tmp[,1]

tmp <- read.csv("./precipitationType2013/precipitationRain2013.csv", header=TRUE)
rain <- data.frame(tmp[,3:15])
rownames(rain) <- tmp[,1]

tmp <- read.csv("./precipitationType2013/precipitationSnow2013.csv", header=TRUE)
snow <- data.frame(tmp[,3:15])
rownames(snow) <- tmp[,1]

tmp <- read.csv("./precipitationType2013/precipitationFog2013.csv", header=TRUE)
fog <- data.frame(tmp[,3:15])
rownames(fog) <- tmp[,1]

shinyServer(function(input, output, session) {

# select dataset if choice is precipitation amount
precAmount <- reactive({
	if (input$year == "2013") {
		dataset <- prec13 }
	else {
		dataset <- prec08 }
	return(dataset)
})

# select dataset if choice is humidity
humid <- reactive({
	if (input$humid == "2013") {
		dataset <- humid13 }
	else {
		dataset <- humid08 }
	return(dataset)
})

# select dataset if choice is precipitation type
precType <- reactive({
	if (input$precType == "Rain") {
		dataset <- rain }
	else if (input$precType == "Snow") {
		dataset <- snow }
	else {
		dataset <- fog }
	return(dataset)
})

# sort which dataset to use (precipitation type or precipitation amount)
whichParameter <- reactive({
	if (input$parameter == "Precipitation amount") {
		dataset <- precAmount()
		}
	else if (input$parameter == "Precipitation type") { 
		dataset <- precType()
		}
	else {
		dataset <- humid()
	}
	return(dataset)
})

# sort which column or row to plot (by city or by month)		
whichVector <- reactive({
	if (input$how == 1) {
		Vector <- as.matrix(whichParameter()[which(rownames(whichParameter())==input$city),])
		}
	else {
		Vector <- whichParameter()[,which(colnames(whichParameter())==input$month)]
		names(Vector) <- rownames(whichParameter())
		}
	
	return(Vector)
})

# decide the title if precipitation amount
precAmountTitle <- reactive({
	if (input$how == 1) {
		Title <- paste("Precipitation (mm)", "|", input$year,"|", input$city)
		}
	else {
		Title <- paste("Precipitation (mm)", "|", input$year,"|", input$month)
		}	
	return(Title)
})

# decide the title if precipitation amount
humidityTitle <- reactive({
	if (input$how == 1) {
		Title <- paste("Humidity (%)", "|", input$humid,"|", input$city)
		}
	else {
		Title <- paste("Humidity (%)", "|", input$humid,"|", input$month)
		}	
	return(Title)
})

# decide on the title if precipitation type
precTypeTitle <- reactive({
	if (input$precType == "Rain") {
		Title <- paste("Rain (days)","|", input$year,"|", input$city)
		}
	else if (input$precType == "Snow") {
		Title <- paste("Snow (days)","|", input$year,"|", input$city)
	}
	else {
		Title <- paste("Fog (days)","|", input$year,"|", input$city)
		}
	return(Title)
})

whichTitle <- reactive({
	if (input$parameter == "Precipitation amount") {
		Title <- precAmountTitle()
		}
	else if (input$parameter == "Precipitation type") {
		Title <- precTypeTitle()
	}
	else {
		Title <- humidityTitle()
	}
	return(Title)
})

	# function to plot the barchart
barchart <- function(x) {
	bp <- barplot(x,
				names.arg= names(x),
				col= "steelblue",
				border= "white",
				axis.lty= 3,
#				ylab="Precipitation (mm)",
				main=whichTitle(),
				cex.names=0.9,
				font=2,
				ylim=c(0,max(x)+50),
				sub=paste("Data from: http://www.stat.gov.mk/Default_en.aspx"))
			
	text(bp, y=x+5, format(x, T), cex=1, font=2)
	}

output$Plot <- renderPlot({
		barchart(whichVector())
	})

output$downloadPlot <- downloadHandler(
	filename= reactive ({ paste(gsub("_"," ",whichTitle()),".pdf",sep="") }),
	
	content= function(file) {
		pdf(file, height=8, width=13)
		barchart(whichVector())
		dev.off()
	},
	
	contentType='application/pdf'
)


output$textAbout <- renderUI({
			HTML(
			"<p>Tool to visualise data for environmental parameters in Macedonia. All data are from the State Statistical Office of Republic of Macedonia (<a href>http://www.stat.gov.mk/Default_en.aspx</a>).</p>"
			)
	})
})

