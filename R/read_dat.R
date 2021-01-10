#' Read a dat file of 5ch and return a data.frame.
#'
#' @param file a path to a dat file.
#' @param br_char a string which represents "<br>" (new line) in responses ("res" in Japanese). Default is "[br]".
#' a string which contains "<" and ">" is not allowed to use.
#' @param encoding encoding of a file. Default is "Shift-JIS".
#'
#' @return a data.frame which contains this columns: dat_id, thread_title, res_number, name, mail, datetime, id, content.
#'
#' Here is a description of each columns.
#'
#' dat_id: character. a filename of a dat file.
#'
#' thread_title: character. a title of a thread.
#'
#' res_number: integer. the number of a response.
#'
#' name: character. a name of a response.
#'
#' mail: character. a string of mail form.
#'
#' datetime: POSIXct. a datetime which a response is posted.
#'
#' id: character. an id of a response.
#'
#' content: character. a content of a response.
#'
#' @importFrom dplyr mutate select filter if_else row_number everything %>%
#' @importFrom tidyr separate fill
#' @importFrom stringr str_trim str_extract str_remove_all str_detect str_c str_sub str_replace_all
#' @importFrom readr read_lines locale
#'
#' @export
#'
#' @examples
#' \dontrun{
#' read_dat("foo.dat",br_char="[br]",encoding="Shift-JIS")
#' }
read_dat <- function(file,br_char="[br]",encoding="Shift-JIS"){
  tryCatch({
    data <- read_lines(file,locale=locale(encoding=encoding))
    res <- data.frame(tmp=data,stringsAsFactors=FALSE) %>%
      separate(col=tmp,into=c("name","mail","datetimeid","content","thread_title"),sep="<>") %>%
      mutate(thread_title=if_else(thread_title=="",NA_character_,thread_title)) %>%
      fill(thread_title,.direction="down") %>%
      mutate(thread_title=str_trim(thread_title)) %>%
      mutate(res_number=row_number()) %>%
      mutate(dat_id=str_extract(file,"[^/]*(?=\\.dat$)")) %>%
      select(dat_id,thread_title,res_number,everything()) %>%
      mutate(name=str_remove_all(name,"<.*?>")) %>%
      filter(datetimeid!="Over 1000 Thread") %>%
      separate(col=datetimeid,into=c("datetime","id"),sep=" (?=ID)") %>%
      mutate(datetime=if_else(str_detect(datetime,"NY:AN:NY\\.AN"),
                              str_c(str_sub(datetime,start=1,end=10)," 00:00:00.00"),datetime)) %>%
      mutate(datetime=str_remove_all(datetime,pattern="\\(.\\)") %>%
               as.POSIXct(format="%Y/%m/%d %H:%M:%OS")) %>%
      mutate(id=str_remove_all(id," .*")) %>%
      mutate(content=str_replace_all(content," <br> ",br_char)) %>%
      mutate(content=str_remove_all(content,"<.*?>")) %>%
      mutate(content=str_replace_all(content,"&gt;",">")) %>%
      mutate(content=str_trim(content,side="both"))
    return(res)
  },
  error=function(e){
    print(file)
    message(e,"\n")
    return(NULL)
  })
}
