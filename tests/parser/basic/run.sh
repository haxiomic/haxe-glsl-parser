#!/bin/bash

if haxe build.hxml; then
	neko bin/main.n
fi
