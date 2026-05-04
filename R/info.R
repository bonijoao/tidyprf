#' Variable descriptions for get_accidents()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_accidents <- function(lang = "en") {
  .info_for("accidents", lang)
}

#' Variable descriptions for get_crashes()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_crashes <- function(lang = "en") {
  .info_for("crashes", lang)
}

#' Variable descriptions for get_violations()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_violations <- function(lang = "en") {
  .info_for("violations", lang)
}

.info_for <- function(dataset, lang) {
  if (!lang %in% c("en", "pt")) {
    cli::cli_abort(
      "{.arg lang} must be {.val en} or {.val pt}, not {.val {lang}}."
    )
  }
  desc_col <- if (lang == "en") "description_en" else "description_pt"

  dplyr::filter(codebook, .data$dataset == !!dataset) |>
    dplyr::select("variable", "type", description = !!desc_col)
}
