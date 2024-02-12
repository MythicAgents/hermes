from mythic_container.MythicCommandBase import *
import json


class SetEnvArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line) == 0:
            raise Exception("No arguments given. Must be of format 'setenv NAME VALUE'")
        pass


class SetEnvCommand(CommandBase):
    cmd = "setenv"
    needs_admin = False
    help_cmd = "setenv [name] [value]"
    description = "Sets an environment variable to your choosing. If you specify an existing environment variable, this will overwrite the value."
    version = 1
    author = "@slyd0g"
    argument_class = SetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass