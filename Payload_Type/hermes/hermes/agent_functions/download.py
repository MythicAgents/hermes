from mythic_container.MythicCommandBase import *
import json
from mythic_container.MythicRPC import *


class DownloadArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                temp_json = json.loads(self.command_line)
                if "host" in temp_json:
                    self.command_line = temp_json["path"] + "/" + temp_json["file"]
                else:
                    raise Exception("Unsupported JSON")
        else:
            raise Exception("Must provide a path to download")


class DownloadCommand(CommandBase):
    cmd = "download"
    needs_admin = False
    help_cmd = "download /path/to/remote/file"
    description = "Download a file from the victim machine to the Mythic server in chunks (no need for quotes in the path)."
    version = 1
    supported_ui_features = ["file_browser:download"]
    author = "@slyd0g"
    parameters = []
    attackmapping = ["T1020", "T1030", "T1041"]
    argument_class = DownloadArguments
    browser_script = BrowserScript(script_name="download_new", author="@its_a_feature_", for_new_ui=True)

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
            artifact="$.NSFileHandle.fileHandleForReadingAtPath, readDataOfLength",
            artifact_type="API Called",
        )
        return task

    async def process_response(self, response: AgentResponse):
        pass
