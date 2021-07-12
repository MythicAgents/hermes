from mythic_payloadtype_container.PayloadBuilder import *
from mythic_payloadtype_container.MythicCommandBase import *
import asyncio
import os
from distutils.dir_util import copy_tree
import shutil
import tempfile
import fileinput
import subprocess

# define your payload type class here, it must extend the PayloadType class though
class Hermes(PayloadType):

    name = "hermes"  # name that would show up in the UI
    file_extension = ""  # default file extension to use when creating payloads
    author = "@slyd0g"  # author of the payload type
    supported_os = [SupportedOS.MacOS]  # supported OS and architecture combos
    wrapper = False  # does this payload type act as a wrapper for another payloads inside of it?
    wrapped_payloads = []  # if so, which payload types. If you are writing a wrapper, you will need to modify this variable (adding in your wrapper's name) in the builder.py of each payload that you want to utilize your wrapper.
    note = """This payload uses Swift for execution on macOS boxes"""
    supports_dynamic_loading = False  # setting this to True allows users to only select a subset of commands when generating a payload
    build_parameters = {
        #  these are all the build parameters that will be presented to the user when creating your payload
        "version": BuildParameter(
            name="version",
            parameter_type=BuildParameterType.ChooseOne,
            description="Choose a target macOS version (Mojave, Catalina, Big Sur)",
            choices=["10.14", "10.15", "10.16"],
        ),
    }
    #  the names of the c2 profiles that your agent supports
    c2_profiles = ["http"]
    support_browser_scripts = [
        BrowserScript(script_name="create_table", author="@its_a_feature_")
    ]
    # after your class has been instantiated by the mythic_service in this docker container and all required build parameters have values
    # then this function is called to actually build the payload
    async def build(self) -> BuildResponse:
        # this function gets called to create an instance of your payload
        resp = BuildResponse(status=BuildStatus.Error)

        # get version parameter from Mythic
        target_version = self.get_parameter("version")
git statu
        try:
            # Copy backup config to config.swift, open it for reading, read data
            agent_config_bak_path = "/Mythic/agent_code/Hermes/config.swift.bak"
            agent_config_path = "/Mythic/agent_code/Hermes/config.swift"
            shutil.copyfile(agent_config_bak_path, agent_config_path)
            config_file = open(agent_config_path, "rt")
            data = config_file.read()

            # pull user agent, host header, and custom headers from c2info
            user_agent = ""
            host_header = ""
            http_headers = ""
            
            # get c2 profile
            c2 = self.c2info[0]
            profile = c2.get_c2profile()["name"]

            # parse user agent, host header, and custom headers
            for key, val in c2.get_parameters_dict().items():
                if key == "headers":
                    hl = val
                    hl = {n["key"]:n["value"] for n in hl}
                    for key,value in hl.items:
                        if "User-Agent" in key:
                            user_agent = value
                        elif "Host" in key:
                            host_header = value
                        else:
                            http_headers += f'"{key}"' + ":" + f'"{value}"' + ","#"key1":"value1","key2":"value2"
            
            # strip trailing comma out of http_headers
            if http_headers[-1] == ",":
                http_headers = http_headers[:-1]

            # check if callback host is using SSL
            use_ssl = "false"
            if "https" in self.c2info[0].get_parameters_dict()["callback_host"]:
                use_ssl = "true"

            # loop through file, replace config
            data = data.replace("REPLACE_PAYLOAD_UUID", self.uuid)
            data = data.replace("REPLACE_ENCODED_AES_KEY", self.c2info[0].get_parameters_dict()["AESPSK"]["enc_key"])
            data = data.replace("REPLACE_CALLBACK_HOST", (self.c2info[0].get_parameters_dict()["callback_host"]).replace("https://","").replace("http://",""))
            data = data.replace("REPLACE_GET_REQUEST_URI", "/" + self.c2info[0].get_parameters_dict()["get_uri"])
            data = data.replace("REPLACE_POST_REQUEST_URI", "/" + self.c2info[0].get_parameters_dict()["post_uri"])
            data = data.replace("REPLACE_CALLBACK_PORT", self.c2info[0].get_parameters_dict()["callback_port"])
            data = data.replace("REPLACE_QUERY_PARAMETER", self.c2info[0].get_parameters_dict()["query_path_name"])
            data = data.replace("REPLACE_SLEEP", self.c2info[0].get_parameters_dict()["callback_interval"])
            data = data.replace("REPLACE_JITTER", self.c2info[0].get_parameters_dict()["callback_jitter"])
            data = data.replace("REPLACE_KILL_DATE", self.c2info[0].get_parameters_dict()["killdate"])
            data = data.replace("REPLACE_USER_AGENT", user_agent)
            data = data.replace("REPLACE_HOST_HEADER", host_header)
            data = data.replace("REPLACE_USE_SSL", use_ssl)
            data = data.replace("REPLACE_HTTP_HEADERS", http_headers)
            config_file.close()
             
            # overwrite the input file
            config_file = open(agent_config_path, "wt")
            config_file.write(data)
            config_file.close()

            # ensure swift compiler is installed
            xcode_install = '/usr/libexec/darling/bin/bash -c "yes | xcode-select --install"'
            p = subprocess.Popen(xcode_install, shell=True)
            p.wait()

            # setup build command
            command = '/usr/libexec/darling/bin/bash -c "swiftc -swift-version 4 -import-objc-header Hermes-Bridging-Header.h *.swift commands/* swift_libraries/* -o hermes -target x86_64-apple-macosx{version} -static-stdlib"'.format(version=target_version)

            # build Hermes
            proc = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd="/Mythic/agent_code/Hermes/",
            )

            # Collect and data written Standard Output and Standard Error
            stdout, stderr = await proc.communicate()
            if stdout:
                resp.build_stdout += f"\n[STDOUT]\n{stdout.decode()}"
            if stderr:
                resp.build_stderr += f"\n[STDERR]\n{stderr.decode()}"

            # get built file
            if os.path.exists("/Mythic/agent_code/Hermes/hermes"):
                resp.payload = open("/Mythic/agent_code/Hermes/hermes", "rb").read()

            # Successfully created the payload without error
            resp.build_message += f'\nCreated Hermes payload!\n' \
                                  f'OS: {target_version}, ' \
                                  f'C2 Profile: {profile}\n'
            resp.status = BuildStatus.Success
            return resp

        except Exception as e:
            resp.build_stderr += "\n" + str(e)
        return resp