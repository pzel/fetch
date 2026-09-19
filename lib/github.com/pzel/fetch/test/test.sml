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


(* RFC 3986 section 2.3 Unreserved Characters (January 2005)
A	B	C	D	E	F	G	H	I	J	K	L	M	N	O	P	Q	R	S	T	U	V	W	X	Y	Z
a	b	c	d	e	f	g	h	i	j	k	l	m	n	o	p	q	r	s	t	u	v	w	x	y	z
0	1	2	3	4	5	6	7	8	9	-	.	_	~
*)

val b = Bytestring.fromString

val encodeTests = [
  It "encodes the empty query" (
    fn()=> let val op == = Assert.eq PolyML.makestring
           in Fetch.encodeQuery [] == ""
           end
  )
, It "encodes regular ascii"(
    fn()=> let val op == = Assert.eq PolyML.makestring
           in Fetch.encodeQuery [("page", b "introduction")]
              == "page=introduction"
           end)
, It "escapes non-letters"(
    fn()=> let val op == = Assert.eq PolyML.makestring
           in Fetch.encodeQuery [("stuff", b "a space,100%.txt")]
              == "stuff=a%20space%2C100%25.txt"
           end)
, It "encodes binary"(
    fn()=> let val op == = Assert.eq PolyML.makestring
               val hex = Option.valOf o Bytestring.fromStringHex
           in Fetch.encodeQuery [("infoHash", hex "0102030405060a0f")]
              == "infoHash=%1%2%3%4%5%6%A%F"
           end)
, It "joins multiple values"(
    fn()=> let val op == = Assert.eq PolyML.makestring
           in Fetch.encodeQuery [("page", b "01"), ("title", b "sam&max")]
              == "page=01&title=sam%26max"
           end)
, It "can construct a url with params"(
    fn()=> let val op == = Assert.eq PolyML.makestring
           in Fetch.url "http://example.com" [("page", b "01"), ("title", b "sam&max")]
              == "http://example.com?page=01&title=sam%26max"
           end)
]


val smokeTest = Pending "fetches quotes via https" (
      fn()=>
         let val res = Fetch.getJson "https://bible-api.com/matt+25:31-33" dec (* quoteDecoder*)
         in res == INR
                     ("Matthew 25:31-33", "web", "World English Bible",
                      [("MAT", "Matthew", 25, 31, "\n"),
                       ("MAT", "Matthew", 25, 32,
                        "\nBefore him all the nations will be gathered, and he will separate them one from another, as a shepherd separates the sheep from the goats.\n\n"),
                       ("MAT", "Matthew", 25, 33,
                        "\nHe will set the sheep on his right hand, but the goats on the left.\n\n")])
         end)

fun main () = runTests (smokeTest::encodeTests)
