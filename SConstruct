#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
# env.Append(CPPPATH=["plugin/", "headers/"])
env.Append(CPPPATH=["plugin/", "headers/", "C:/Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/um/"])
# env.Append(CPPPATH=["D:/CPP_Libs/boost_1_76_0"])

# env.Append(CPPPATH=['C:/Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/um/'])
env.Append(LIBPATH=['C:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/'])
# env.Append(LIBPATH=['C:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/ws2_32'])
sources = [Glob("plugin/*.cpp"), Glob("plugin/src/*.cpp")]

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "main/bin/libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "main/bin/libgdexample{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
