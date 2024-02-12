from mythic_container.MythicCommandBase import *
import json


class CdArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass

class CdCommand(CommandBase):
    cmd = "cd"
    needs_admin = False
    help_cmd = "cd [new directory]"
    description = "Change directory to [path]. Path relative identifiers such as ../ are accepted."
    version = 1
    author = "@slyd0g"
    argument_class = CdArguments
    attackmapping = ["T1005"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
