from mythic_container.MythicCommandBase import *
import json


class CatArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class CatCommand(CommandBase):
    cmd = "cat"
    needs_admin = False
    help_cmd = "cat [file path]"
    description = "Return contents of a file as a string."
    version = 1
    author = "@slyd0g"
    argument_class = CatArguments
    attackmapping = ["T1005"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
