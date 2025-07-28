## wrap 508 is used by naming the tag type ("H2", "H3", "P", etc) then copying the R/LaTeX code into the text argument
wrap508 <- function(tag, text, alt = NA, width = NA, height = NA, alttext = NA) {
  if (is.na(alt)) {
    alt <- alttext
  }
  if (!is.na(width)) {
    if (!is.na(alt) & alt != "") {
      paste0(
        "\\tagstructbegin{tag=", tag, ",alt={", alt, "}}\\tagmcbegin{tag=", tag, ",alt={", alt, "}}",
        "\\includegraphics[width=", width, ",height=", height, "]{", text, "}", "\\tagmcend\\tagstructend"
      )
    } else {
      paste0(
        "\\tagstructbegin{tag=", tag, "}\\tagmcbegin{tag=", tag, "}",
        "\\includegraphics[width=", width, ",height=", height, "]{", text, "}", "\\tagmcend\\tagstructend"
      )
    }
  } else {
    if (!is.na(alt) & alt != "") {
      paste0("\\tagstructbegin{tag=", tag, ",alt={", alt, "}}\\tagmcbegin{tag=", tag, ",alt={", alt, "}}", text, "\\tagmcend\\tagstructend")
    } else {
      paste0("\\tagstructbegin{tag=", tag, "}\\tagmcbegin{tag=", tag, "}", text, "\\tagmcend\\tagstructend")
    }
  }
}
beginTag <- function(tag, alt = NA, alttext = NA) {
  if (is.na(alt)) {
    alt <- alttext
  }
  if (!is.na(alt) & alt != "") {
    paste0("\\tagstructbegin{tag=", tag, ",alt={", alt, "}}\\tagmcbegin{tag=", tag, ",alt={", alt, "}}")
  } else {
    paste0("\\tagstructbegin{tag=", tag, "}\\tagmcbegin{tag=", tag, "}")
  }
}
endTag <- function() {
  paste0("\\tagmcend\\tagstructend")
}
bullet508 <- function(text, position) {
  if (missing(position)) position <- ""

  if (position == "head") {
    tag <- "\\tagstructbegin{tag=L}"
  } else {
    tag <- ""
  }

  tag <- paste0(tag, "\\tagstructbegin{tag=LI} \\tagstructbegin{tag=LBody} \\tagmcbegin{tag=P} ", text, " \\tagmcend \\tagstructend \\tagstructend")

  if (position == "tail") {
    tag <- paste0(tag, "\\tagstructend")
  }

  return(tag)
}
