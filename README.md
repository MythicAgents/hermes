# Hermes

<p align="center">
  <img alt="Hermes Logo" src="agent_icons/hermes.svg" height="30%" width="30%">
</p>

Hermes is a macOS agent written in Swift 5 designed for red team operations.

## Installation
Hermes currently supports Mythic 2.3.

Hermes requires the [Darling kernel module](https://github.com/darlinghq/darling/releases/download/v0.1.20210224/darling-dkms_0.1.20210224.testing_amd64.deb) to perform cross-compilation on the Mythic server.

It is tested for Ubuntu 20.10. After installing the Darling kernel module, as root, run `modprobe darling-mach` before starting the Hermes container

To install Hermes, you'll need Mythic installed on a remote computer. You can find installation instructions for Mythic at the [Mythic project page](https://github.com/its-a-feature/Mythic/).

From the Mythic install directory, use the following command to install Hermes as the **root** user:

```
./mythic-cli install github https://github.com/MythicAgents/hermes.git
```

From the Mythic install directory, use the following command to install Hermes as a **non-root** user:

```
sudo -E ./mythic-cli install github https://github.com/MythicAgents/hermes.git
```

Once installed, restart Mythic to build a new agent.

## Notable Features
- Cross-compiling macOS payloads from Ubuntu using Darling
- Ability to load and execute JXA scripts in-memory
- Various macOS situational awareness techniques
- Upload/download
- Full file system access (ls, mv, cp, mkdir, cd, etc.)

## Commands Manual Quick Reference

Command | Syntax | Description
------- | ------ | -----------
cat | `cat [file]` | Retrieve the output of a file
cd | `cd [directory]` | Change current directory
clipboard | `clipboard` | Monitor the clipboard for paste events. Manually stop this job with `jobkill`
cp | `cp [source] [destination]` | Copy a file
download | `download [file]` | Download a file from the target
env | `env` | List environment variables
exit | `exit` | Task agent to exit
fda_check | `fda_check` | Attempt to open a file handle to `~/Library/Application\ Support/com.apple.TCC/TCC.db` to determine if you have `Full Disk Access`
get_execution_context | `get_execution_context` | Read environment variables to determine payload execution context
hostname | `hostname` | Gather hostname information
ifconfig | `ifconfig` | Gather IP addresses
jobkill | `jobkill [jobID]` | Kill a running job by ID
jobs | `jobs` | List running jobs
jxa | `jxa {"code" : "Math.PI"}` | Execute JXA code
jxa_call | `jxa_call [function]` | Execute JXA functions from an uploaded script, upload JXA scripts into memory with `jxa_import`
jxa_import | `jxa_import` | Use modal popup to upload JXA script into agent memory, call functions with `jxa_call`
list_apps | `list_apps` | List running applications with `NSApplication.RunningApplications`
list_tcc | `list_tcc [TCC.db file]` | Lists entries in TCC database (requires Full Disk Access). Schema currently only supports Big Sur
ls | `ls [path]` | List files and folders for a directory. Use `ls .` for current directory
mkdir | `mkdir [directory]` | Create a directory
mv | `mv [source] [destination]` | Move a file from source to destination
plist_print | `plist_print [file]` | Retrive contents of plist file. Supports JSON, XML, and binary
ps | `ps` | List process information
pwd | `pwd` | Print working directory
rm | `rm [path]` | Remove a file or directory
run | `run [/bin/slyd0g] [arguments]` | Execute a binary on disc with arguments
screenshot | `screenshot` | Capture all connected displays in-memory and send it back over the C2 channel, requires `Screen Recording` permissions
setenv | `setenv [name] [value]` | Set an environment variable, will overwrite existing
shell | `shell [command]` | Execute a shell command with `/bin/bash -c`
sleep | `sleep [seconds] [percentage]` | Set the callback interval of the agent in seconds with a percentage for jitter
tcc_folder_checker | `tcc_folder_checker` | Run from a Terminal context to check access to TCC-protected folders: `~/Downloads`, `~/Desktop`, `~/Documents`
unsetenv | `unsetenv [name]` | Unset an environment variable
upload | `upload` | Use modal popup to upload a file to a remote path on the target
whoami | `whoami` | Gather current user context

## Supported C2 Profiles

### [HTTP Profile](https://github.com/MythicC2Profiles/http)

The HTTP profile calls back to the Mythic server over the basic, non-dynamic profile. When selecting options to be stamped into Hermes at compile time, all options are respected with the exception of those parameters related to proxy servers.

## Thank you

Hermes icon made by [Freepik](https://www.flaticon.com/authors/freepik)
