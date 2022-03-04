from mythic_payloadtype_container.MythicCommandBase import *
import json


class WhoAmIArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class WhoAmICommand(CommandBase):
    cmd = "whoami"
    needs_admin = False
    help_cmd = "whoami"
    description = "Call NSUsername() to get the logon name of the current user"
    version = 1
    author = "@slyd0g"
    argument_class = WhoAmIArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass