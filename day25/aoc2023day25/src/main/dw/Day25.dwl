%dw 2.0
import * from dw::core::Strings

fun load(filename: String) = 
    lines(readUrl("classpath://$(filename)", "text/plain"))
