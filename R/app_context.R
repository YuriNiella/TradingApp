#========================================================
# Application Context
#========================================================

create_app_context <- function(){

    cache_create()

    con <- database_connect(
        config$paths$database
    )

    database_initialize(con)

    list(

        config = config,

        con = con

    )

}