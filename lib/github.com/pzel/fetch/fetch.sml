structure Fetch = struct

type options = {
  method: string
}

local
fun optionsToList (url: string, {method}: options) : string list =
    [url ,"--request", method, "--silent", "--show-error", "--stderr", "-"]

fun percentEncode (c: Word8.word) : string =
    let open Word8
    in if (0w65 <= c andalso c <= 0w90) orelse
          (0w97 <= c andalso c <= 0w122) orelse
          (0w48 <= c andalso c <= 0w57) orelse
          c = 0w45 orelse c = 0w46 orelse
          c = 0w95 orelse c = 0w126
       then String.implode [chr (toInt c)]
       else "%"^toString c
    end

val clean = String.concat o map percentEncode o Bytestring.explode

in

fun encodeQuery (params: (string * Bytestring.string) list) : string =
    String.concatWith "&" (map (fn (k,v) => k ^ "=" ^ clean v) params)

fun url (base: string) (params: (string * Bytestring.string) list) : string =
    base ^ "?" ^ encodeQuery params

fun fetch (url: string) (options: options) (body: string option) : (string, string) sum =
    let val proc = Unix.execute("/usr/bin/curl", optionsToList(url, options))
        val s = Unix.textInstreamOf proc
        val res = TextIO.inputAll s
        val _ = TextIO.closeIn s
        val status = Unix.reap(proc)
    in if OS.Process.isSuccess status
       then INR res
       else INL res (* cheezy string error *)
    end handle exn => INL (exnMessage exn)

fun get (url: string) : (string, string) sum = fetch url {method= "GET"} NONE

fun getJson (url: string) (d: 'a JsonCvt.decoder) : (string,'a) sum =
    get url >| Either.bindRight (JsonCvt.decodeString d)

end
end
