#========================================================
# Cache Engine
#========================================================

cache_path <- function(...){

    file.path(

        config$cache$path,

        ...

    )

}

cache_create <- function(){

    dirs <- c(

        cache_path(),

        cache_path("yahoo"),

        cache_path("yahoo","metadata"),

        cache_path("prices"),

        cache_path("market")

    )

    for(dir in dirs){

        if(!dir.exists(dir))

            dir.create(

                dir,

                recursive = TRUE

            )

    }

}

metadata_cache_file <- function(

    ticker

){

    cache_path(

        "yahoo",

        "metadata",

        paste0(

            ticker,

            ".rds"

        )

    )

}

metadata_cache_read <- function(

    ticker

){

    file <- metadata_cache_file(

        ticker

    )

    if(!file.exists(file))

        return(NULL)

    age <-

        Sys.time() -

        file.info(file)$mtime

    if(age >

       config$cache$metadata_days * 86400){

        return(NULL)

    }

    readRDS(file)

}

metadata_cache_write <- function(

    ticker,

    metadata

){

    saveRDS(

        metadata,

        metadata_cache_file(

            ticker

        )

    )

}

cache_statistics <- function(){

    files <- list.files(

        cache_path(

            "yahoo",

            "metadata"

        ),

        full.names = TRUE

    )

    data.frame(

        files = length(files),

        size_mb =

            round(

                sum(

                    file.info(files)$size

                ) / 1024^2,

                2

            )

    )

}



