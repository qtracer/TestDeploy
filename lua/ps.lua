local uri = ngx.var.uri;
local args = ngx.req.get_uri_args();
local name = args["name"];

local headers = ngx.req.get_headers();
local dirpath = headers["dirpath"];
local shellpath = headers["shellpath"];

local shellCommand = "cd "..dirpath.." && bash "..shellpath.."/main-cli.sh "..name

local shell = require "resty.shell"

local args = {
  socket = "unix:/data/tomcattemp/shell.sock"
}

local status, out, err = shell.execute(shellCommand, args)
ngx.header.content_type = "text/plain"
ngx.say("Result:"..shellCommand.."\n" .. out)
