universe <- download_universe()

universe <- clean_universe(universe)

universe <- enrich_universe(universe)

save_universe(universe)