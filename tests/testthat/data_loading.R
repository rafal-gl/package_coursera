test_that("check example data loading", 
          {
            file_path <- system.file("extdata", package = "fars.pack")
            setwd(file_path)
            fars2015 <- fars_read(dir()[1])
            expect_that(fars2015, is.data.frame)
            expect_that(dim(fars2015), equals(c(32166,52)))
          })
