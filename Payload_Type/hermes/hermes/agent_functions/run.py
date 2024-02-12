from mythic_container.MythicCommandBase import *
import json
from mythic_container.MythicRPC import *


class RunArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class RunCommand(CommandBase):
    cmd = "run"
    needs_admin = False
    help_cmd = "run [/path/to/binary] [argument1] [argument2] ..."
    description = "Execute a binary on disc with arguments"
    version = 1
    author = "@slyd0g"
    argument_class = RunArguments
    attackmapping = ["T1106"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
