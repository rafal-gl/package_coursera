#####################################################################
# Skrypt do budowy kolejnych wersji pakietu
# Autor: Rafał Głąbski
#####################################################################

library(devtools)
library(roxygen2)
library(stringr)
library(dplyr)

package_name <- "fars.pack"

old_wd <- getwd()
# ścieżka do folderu gdzie powstaną pliki pakietowe
# musi zawierać podfolder z wszystkimi funkcjami do pakietu o nazwie
# nazwapakietu_funkcje
package_dir <- "C:/Users/Public/szkolenieR/package_coursera"
# ścieżka z poprzednimi wersjami pakietu
# old_versions_dir <- "C:/Users/Public/szkolenieR/package_coursera"

setwd(package_dir)
options(devtools.desc.author="'First Last <first.last@example.com> [aut, cre]'")
unlink(package_name, recursive = TRUE)

### Numer następnej wersji ###
# Za change_ind wybierz liczbę od 1 do 4, im mniejsza tym ważniejsza zmiana 
# 1 - rewolucja
# 2 - nowe funkcje
# 3 - zmiana działania którejś z funkcji
# 4 - debug
change_ind = 4
change_levels = c("major", "minor", "build", "revision")

vers = grep(".tar.gz", dir(old_versions_dir), 
            value = TRUE)
vers = unlist(str_extract_all(vers, "\\d(\\.(\\d)+)*"))
last_ver = vers[rank(-as.numeric(gsub('\\.', '', vers)))[1]]
last_ver_num = as.numeric(strsplit(last_ver, "\\.")[[1]])
last_ver_num = c(last_ver_num, 
                 rep(0, length(change_levels) - length(last_ver_num)))
new_ver_num = last_ver_num
new_ver_num[change_ind] = new_ver_num[change_ind] + 1
if(change_ind < length(change_levels)) {
  new_ver_num[(change_ind + 1) : length(new_ver_num)] = 0
} 
new_ver = paste(new_ver_num, collapse = ".")
new_ver <- "0.1.0.0"


create(path = package_name,
       description = list(Title = "Title",
                          Version = new_ver,
                          Description = "Description",
                          License = "Internal use only",
                          "Authors@R" = "c(person(given = \"Rafal\", family = \"Glabski\", email = \"rafalglabski@gmail.com\", role = c(\"aut\", \"cre\")))", 
                          Author = "Rafal Glabski",
                          Maintainer = "Rafal Glabski <rafalglabski@gmail.pl>",
                          # Hadley mówi, żeby wypisywać tylko Imports, a zamiast Depends
                          # używać tylko package::function albo requireNamespace,
                          # ale tak jest wygodniej :P
                          #Depends = "broom, C50, DBI, dplyr, geosphere, ggmap, ggplot2, methods, partykit, purrr, reshape2, rgeos, rJava, RJDBC, rjson, ROCR, RODBC, sp, stringr, tcltk, xtable",
                          Imports = "broom, C50, DBI, dplyr, geosphere, ggmap, ggplot2, methods, partykit, purrr, reshape2, rgeos, rJava, RJDBC, rjson, ROCR, RODBC, sp, stringr, tcltk, xtable",
                          Encoding = "UTF-8"))

file.copy("fars_functions.R",
  # list.files(paste0(package_name, "_funkcje"), 
                     # full.names = TRUE),
          to = paste0(package_name, "/R"))
setwd(paste0("./", package_name))
document()
setwd("..")
install(package_name)
library(...)
# check(package_name)

build(pkg = package_name, path = old_versions_dir)

setwd(old_wd)

# dokumentacja
# pack <- package_name
# path <- find.package(pack)
# system(paste(shQuote(file.path(R.home("bin"), "R")),
#              "CMD", "Rd2pdf", shQuote(path)))