from mythic_payloadtype_container.MythicCommandBase import *
import json


class PsArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class PsCommand(CommandBase):
    cmd = "ps"
    needs_admin = False
    help_cmd = "ps"
    description = "Gather list of running processes."
    version = 1
    supported_ui_features = ["process_browser:list"]
    author = "@slyd0g"
    argument_class = PsArguments
    attackmapping = ["T1057"]
    browser_script = BrowserScript(script_name="ps_new", author="@djhohnstein", for_new_ui=True)

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
