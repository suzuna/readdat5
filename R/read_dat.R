#' Read a dat file of 5ch and return a tibble
#'
#' @param file a string. a path to a dat file.
#' @param br_char a string which represents "<br>" (new line) in responses ("res" in Japanese).
#' It is not allowed to use a string which contains "<" and ">".
#' @param encoding a string. encoding of a file.
#'
#' @return a tibble. Here is columns of the tibble.
#' \itemize{
#'   \item{dat_id} {character. a filename of a dat file.}
#'   \item{thread_title} {character. a title of a thread.}
#'   \item{res_number} {integer. the number of a response.}
#'   \item{name} {character. a name of a response.}
#'   \item{mail} {character. a string of mail form.}
#'   \item{datetime} {character. a datetime which a response is posted.}
#'   \item{id} {character. an id of a response.}
#'   \item{be} {character. a be of a response.}
#'   \item{content} {character. a content of a response.}
#' }
#' @examples
#' \dontrun{
#' read_dat("foo.dat",br_char="[br]",encoding="Shift-JIS")
#' }
#' @export
read_dat <- function(file,br_char="[br]",encoding="Shift-JIS") {
  data_raw_list <- readr::read_lines_raw(file)
  data <- stringi::stri_encode(data_raw_list,from=encoding) %>%
    stringr::str_remove_all("\ufffd")

  res <- tibble::tibble(tmp=data) %>%
    tidyr::separate(col=tmp,into=c("name","mail","datetime_id_be","content","thread_title"),sep="<>",fill="right")
  res <- res %>%
    dplyr::mutate(dat_id=stringr::str_extract(file,"[^/]*(?=\\.dat$)")) %>%
    dplyr::mutate(res_number=dplyr::row_number()) %>%
    dplyr::mutate(
      thread_title=dplyr::if_else(thread_title=="",NA_character_,thread_title) %>%
        stringr::str_trim(side="both")
    ) %>%
    tidyr::fill(thread_title,.direction="down") %>%
    dplyr::mutate(name=stringr::str_remove_all(name,"<.*?>"))
  res <- res %>%
    dplyr::filter(datetime_id_be!="Over 1000 Thread")
  res <- res %>%
    tidyr::separate(col=datetime_id_be,into=c("datetime","id_be"),sep=" (?=ID:)",fill="right") %>%
    tidyr::separate(col=id_be,into=c("id","be"),sep=" (?=BE:)",fill="right") %>%
    dplyr::mutate(id=stringr::str_remove_all(id," .*")) %>%
    dplyr::mutate(
      datetime=dplyr::if_else(
        stringr::str_detect(datetime,"NY:AN:NY\\.AN"),
        stringr::str_c(stringr::str_sub(datetime,start=1,end=10)," 00:00:00.00"),
        datetime
      ) %>%
        stringr::str_remove_all(pattern="\\(.\\)")
    )
  res <- res %>%
    dplyr::mutate(
      content=stringr::str_replace_all(content," <br> ",br_char) %>%
        stringr::str_remove_all("<.*?>") %>%
        stringr::str_replace_all(c(
          "&gt;"=">",
          "&lt;"="<",
          "&amp;"="&",
          "&quot;"='"'
        )) %>%
        stringr::str_trim(side="both")
    )
  res <- res %>%
    dplyr::relocate(dat_id,thread_title,res_number,name,mail,datetime,id,be,content)
  return(res)
}

#' Unescape character references
#' @param str a string vector.
#' @return a string vector.
#' @export
unescape_character_reference <- function(str) {
  purrr::map_chr(str,function(x) {
    xml2::xml_text(xml2::read_html(stringr::str_c("<text>",x,"</text>")))
  })
}
