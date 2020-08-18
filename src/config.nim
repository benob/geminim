import parsecfg, strutils, strtabs, os

type Settings* = object
  vhost*: StringTableRef
  port*: int
  certFile*, keyFile*: string

proc get(dict: Config, value, default: string, section = ""): string =
  result = dict.getSectionValue(section, value)
  if result.len < 1: return default

proc readSettings*(path: string): Settings =
  let conf = loadConfig(path)

  result = Settings(
    vhost: newStringTable(modeCaseSensitive),
    port: conf.get("port", "1965").parseInt,
    certFile: conf.get("certFile", "mycert.pem"),
    keyFile: conf.get("keyFile", "mykey.pem"))

  for rawHostname in conf.get("hostnames", "localhost").split(','):
    let
      hostname = rawHostname.strip
      dir = conf.get("dir", hostname, section = hostname)
    if dirExists(dir): result.vhost[hostname] = dir
    else: echo "Directory " & dir & " does not exist. Not adding to hosts."
