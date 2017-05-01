#!/usr/bin/env io
/*
 * Copyright 2017 Yoshihiro Tanaka
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Yoshihiro Tanaka <contact@cordea.jp>
 * date  : 2017-04-27
 */

Importer addSearchPath("./io-OptionParser")

regex := Regex
cgi := CGI

OperatorTable addAssignOperator(":", "parse")

curlyBrackets := method(
    map := Map clone
    call message arguments foreach(v, map doMessage(v))
)

squareBrackets := method(
    lst := list()
    call message arguments foreach(v, lst push(doMessage(v)))
)

Map parse := method(v1, v2,
    self atPut(
        v1 exSlice(1, -1), v2
    )
)

List += := method(v,
    self push(v)
)

Gnavi := Object clone do(

    // https not supported ...
    base_url := "http://api.gnavi.co.jp/RestSearchAPI/20150630"

    buildUrl := method(token, options,
        url := Gnavi base_url .. "?keyid=" .. token .. "&format=json"
        if(options areaS != "", url = url .. "&areacode_s=" .. (options areaS))
        if(options query != "", url = url .. "&freeword=" .. cgi encodeUrlParam(options query))
        if(options range != 0, url = url .. "&range=" .. (options range))
        if(options latitude != 0, url = url .. "&latitude=" .. (options latitude))
        if(options longitude != 0, url = url .. "&longitude=" .. (options longitude))
        URL with(url)
    )

    request := method(url,
        url fetch
    )

    parse := method(json,
        rests := json at("rest")
        if(rests type == "List",
            rests map(v, (v at("name")) .. "\n\t" .. v at("address") .. "\n\t" .. v at("url")),
            list(rests at("name") .. "\n\t" .. rests at("address") .. "\n\t" .. rests at("url"))
        )
    )
)

Options := Object clone do(
    query := ""
    range := 0
    areaS := ""
    latitude := 0
    longitude := 0
)

as := method(v,
    v matchesOfRegex("u[a-f0-9]{4}") replace(x, ("0x" .. (x string exSlice(1))) toBase(10) asNumber asCharacter)
)

run := method(opts,
    f := File with("credential.txt")
    token := f openForReading contents strip

    url := Gnavi buildUrl(token, opts)

    response := Gnavi request(url)
    Gnavi parse(doString(response)) foreach(v,
        as(v) println
    )
)

gnavi := method(
    parser := OptionParser with(
        list("a", "area", "AREAS3102", ""),
        list("r", "range", 0, ""),
        list("l", "location", "0:0", "")
    ) setDescription(
        ""
    ) setUsage("")

    args := System args rest
    opts := parser parse(args, true)
    if (opts at("help"),
        parser help,
        if(args size == 1, (
            Options query = args first
            Options range = opts at("range")
            Options areaS = opts at("area")
            ls := opts at("location") split(":")
            Options latitude = ls at(0) asNumber
            Options longitude = ls at(1) asNumber
            run(Options)
        ), parser error)
    )
)

if(isLaunchScript, gnavi)
