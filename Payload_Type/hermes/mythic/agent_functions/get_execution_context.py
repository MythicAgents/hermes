from mythic_payloadtype_container.MythicCommandBase import *
import json


class GetExecutionContextArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class GetExecutionContextCommand(CommandBase):
    cmd = "get_execution_context"
    needs_admin = False
    help_cmd = "get_execution_context"
    description = "Check various environment variables to determine execution context. Technique inspired by @cedowens who also implemented this check in https://github.com/cedowens/SwiftBelt"
    version = 1
    author = "@slyd0g"
    argument_class = GetExecutionContextArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass