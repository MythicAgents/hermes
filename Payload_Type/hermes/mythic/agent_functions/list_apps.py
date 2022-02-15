from mythic_payloadtype_container.MythicCommandBase import *
import json
from mythic_payloadtype_container.MythicRPC import *


class ListAppsArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class ListAppsCommand(CommandBase):
    cmd = "list_apps"
    needs_admin = False
    help_cmd = "list_apps"
    description = "This uses NSApplication.RunningApplications to get information about running applications."
    version = 1
    supported_ui_features = ["process_browser:list"]
    author = "@slyd0g"
    attackmapping = ["T1057"]
    argument_class = ListAppsArguments
    browser_script = [BrowserScript(script_name="list_apps", author="@its_a_feature_"),
                      BrowserScript(script_name="list_apps_new", author="@its_a_feature_", for_new_ui=True)]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
            artifact="$.NSWorkspace.sharedWorkspace.runningApplications",
            artifact_type="API Called",
        )
        return task

    async def process_response(self, response: AgentResponse):
        pass
