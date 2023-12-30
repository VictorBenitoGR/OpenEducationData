# * = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# * DataCleaner
# * https://github.com/VictorBenitoGR/DataCleaner
# * = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# *** PACKAGES *** ------------------------------------------------------------

# install.packages("PackageName")

library("dplyr") # Data manipulation/transformation

library("openxlsx") # Reading/writing/editing excel files

library("stringr") # Strings (text) manipulation


# *** FILE *** ----------------------------------------------------------------

getwd() # Change Working Directory with setwd("/path/to/DataCleaner") if needed

dataset <- read.csv("data/dataset.csv") # Change according to your file name

# datasetTest <- head(dataset,1000) # View without loading the entire db

str(dataset) # Quick overview of the general structure


# *** COLUMN NAMES *** --------------------------------------------------------

# * Analyze the clarity of the column names

names(dataset)

# * Select/reorder the relevant columns after select(dataset,___,___,___)

dataset <- select(dataset, fechahoraUTC, Timestamp, idUsuario, idConversacion,
                  idMensaje, canal, categoria, nombreBot, tipo)

# * Rename column names

colnames(dataset) <- c("DateTimeUTC", "DateTimeLocal",  "IDUser",
                       "IDConversation", "IDMessage", "Channel",
                       "Category", "Version", "Type")


# *** FITLER *** --------------------------------------------------------------

# * See the unique entries in each column

levels(factor(dataset$Channel))

levels(factor(dataset$Version))

# * Write here the entries you want to keep, the rest will be omitted

dataset <- dataset[(dataset$Channel == "webchat")
                   & (dataset$Version %in% c("bot-chbot2-tec-prod",
                                             "bot-chbot-tec-prod")),]


# *** DATES AND TIME *** ------------------------------------------------------

# * Redo date and time columns

dataset$DateUTC <- substr(dataset$DateTimeUTC,1,10)

dataset$TimeUTC <- substr(dataset$DateTimeUTC, 12,19)

dataset$DateTimeUTC <- paste(dataset$DateUTC,dataset$TimeUTC, sep = ' ')

dataset$DateTimeUTC <- as.POSIXct(dataset$DateTimeUTC, tz = "UTC")

class(dataset$DateTimeUTC) # The result must be "POSIXct" and "POSIXt"

# * Get local time

# In this example the difference between UTC and Monterrey MX
# is -5 hours, equal to -18000 seconds
dataset$DateTimeLocal <- dataset$DateTimeUTC - 18000

# * Select/reorder the relevant columns after select(dataset,___,___,___)

dataset <- select(dataset, DateTimeUTC, DateTimeLocal, IDUser, IDConversation,
                  IDMessage, Channel, Category, Version, Type)


# *** URL DOMAINS *** ---------------------------------------------------------

# * Get the unique entries to find out how many different domains there are

unique(dataset$Category)

# * It's TRUE when a column result has the URL we want to simplify

dataset$Category <- case_when(
  str_detect(dataset$Category, "experiencia") ~ "Experiencia21",
  str_detect(dataset$Category, "mitec") ~ "MiTec",
  str_detect(dataset$Category, "tecdemonterrey") ~ "TecDeMonterrey",
  str_detect(dataset$Category, "sharepoint") ~ "TecMXSharePoint",
  str_detect(dataset$Category, "ProgramasInternacionales") ~
    "ProgramasInternacionales",
  str_detect(dataset$Category, "localhost") ~ "LocalHost",
  str_detect(dataset$Category, "estadodecuenta") ~ "EstadoDeCuenta",
  TRUE ~ dataset$Category
)

# * Verify that each URL is simplified to their domain name

unique(dataset$Category)


# *** EXPORT *** --------------------------------------------------------------

# The file will be exported to the project's "data" folder

write.csv(dataset, "data/CleanDataset.csv", row.names = FALSE)

# Look at it as a dataframe if you want

CleanDataset <- read.csv("data/CleanDataset.csv")


# *** DELETE TEST *** ---------------------------------------------------------

# * If you are programming for the official repository, make sure that no
# * generated file is going to be pushed.

# testPath <- "data/CleanDataset.csv"

# if (file.exists(testPath)) {
#   file.remove(testPath)
#   cat("File deleted successfully.\n")
# } else {
#   cat("File does not exist.\n")
# }
