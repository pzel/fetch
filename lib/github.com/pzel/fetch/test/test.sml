type verse =
         { bookId: string
         , bookName: string
         , chapter: int
         , verse: int
         , text: string }

type quote =
     { reference: string
     , translationId: string
     , translationName: string
     , verses: verse list }

fun mkVerse id name chapter verse text =
    { bookId = id
    , bookName = name
    , chapter = chapter
    , verse = verse
    , text = text }

fun mkQuote r trId trName vs =
    { reference = r
    , translationId = trId
    , translationName = trName
    , verses = vs }

val quoteDecoder : quote JsonCvt.decoder =
    let open JsonCvt
        val (vd : verse decoder) =
            map5 mkVerse
                 (field "book_id" string)
                 (field "book_name" string)
                 (field "chapter" int)
                 (field "verse" int)
                 (field "text" string)
    in map4 mkQuote
            (field "reference" string)
            (field "translation_id" string)
            (field "translation_name" string)
            (field "verses" (list vd))
    end


val dec = let open JsonCvt
              val vd = map5 tup5
                            (field "book_id" string)
                            (field "book_name" string)
                            (field "chapter" int)
                            (field "verse" int)
                            (field "text" string)
          in map4 tup4
                  (field "reference" string)
                  (field "translation_id" string)
                  (field "translation_name" string)
                  (field "verses" (list vd))
          end

fun fetch (url: string) (d: 'a JsonCvt.decoder) : (string,'a) sum =
    let val proc = Unix.execute("/usr/bin/curl",["-s", url])
        val s = Unix.textInstreamOf proc
        val res = TextIO.inputAll s >| JsonCvt.decodeString d
        val _ = TextIO.closeIn s
        val _ = Unix.kill(proc, Posix.Signal.kill)
    in
      res
    end

fun main () =
    let val res = fetch "https://bible-api.com/matt+25:31-33" dec (* quoteDecoder*)
        val _ = PolyML.print_depth 100
    in
      PolyML.print res
    end

