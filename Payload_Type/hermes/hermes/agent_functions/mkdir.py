from mythic_container.MythicCommandBase import *
import json


class MkdirArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class MkdirCommand(CommandBase):
    cmd = "mkdir"
    needs_admin = False
    help_cmd = "mkdir [new directory]"
    description = "Create a new directory from a full or relative path"
    version = 1
    author = "@slyd0g"
    argument_class = MkdirArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass