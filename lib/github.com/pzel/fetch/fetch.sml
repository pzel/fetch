structure Fetch = struct

type options = {
  method: string
}

fun optionsToList (url: string, {method}: options) : string list =
    [url ,"--request", method, "--silent", "--show-error", "--stderr", "-"]

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
