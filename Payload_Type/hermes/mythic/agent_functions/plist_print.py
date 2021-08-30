from mythic_payloadtype_container.MythicCommandBase import *
import json


class PlistPrintArguments(TaskArguments):
    def __init__(self, command_line):
        super().__init__(command_line)
        self.args = {}

    async def parse_arguments(self):
        pass


class PlistPrintCommand(CommandBase):
    cmd = "plist_print"
    needs_admin = False
    help_cmd = "plist_print [file path]"
    description = "Return contents of a plist file (xml, json, or binary)"
    version = 1
    author = "@slyd0g"
    argument_class = PlistPrintArguments
    attackmapping = ["T1005"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass