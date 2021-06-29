from mythic_payloadtype_container.MythicCommandBase import *
import json
from mythic_payloadtype_container.MythicRPC import *
import sys


class LsArguments(TaskArguments):
    def __init__(self, command_line):
        super().__init__(command_line)
        self.args = {
            "path": CommandParameter(
                name="path",
                type=ParameterType.String,
                default_value=".",
                description="Path of file or folder on the current system to list",
            )
        }

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                temp_json = json.loads(self.command_line)
                if "host" in temp_json:
                    # this means we have tasking from the file browser rather than the popup UI
                    # the hermes agent doesn't currently have the ability to do _remote_ listings, so we ignore it
                    self.add_arg("path", temp_json["path"] + "/" + temp_json["file"])
                    self.add_arg("file_browser", True, type=ParameterType.Boolean)
                else:
                    self.add_arg("path", temp_json["path"])
            else:
                self.add_arg("path", self.command_line)


class LsCommand(CommandBase):
    cmd = "ls"
    needs_admin = False
    help_cmd = "ls /path/to/file"
    description = "Get attributes about a file and display it to the user via API calls. No need for quotes and relative paths are fine"
    version = 2
    author = "@slyd0g"
    attackmapping = ["T1106", "T1083"]
    supported_ui_features = ["file_browser:list"]
    argument_class = LsArguments
    browser_script = [BrowserScript(script_name="ls", author="@its_a_feature_")]
    attributes = CommandAttributes(
        spawn_and_injectable=True,
        supported_os=[SupportedOS.MacOS],
    )

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
            artifact="fileManager.attributesOfItemAtPathError, fileManager.contentsOfDirectoryAtPathError",
            artifact_type="API Called",
        )
        if task.args.has_arg("file_browser") and task.args.get_arg("file_browser"):
            host = task.callback.host
            task.display_params = host + ":" + task.args.get_arg("path")
        else:
            task.display_params = task.args.get_arg("path")
        return task

    async def process_response(self, response: AgentResponse):
        pass
