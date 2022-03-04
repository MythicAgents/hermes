from mythic_payloadtype_container.MythicCommandBase import *
import json


class JXACallArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="command",
                type=ParameterType.String,
                description="The function to execute within a file loaded via jxa_import",
                parameter_group_info=[ParameterGroupInfo()]
            )
        ]

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                self.load_args_from_json_string(self.command_line)
            else:
                self.add_arg("command", self.command_line)
        else:
            raise ValueError("Missing arguments")
        pass


class JXACallCommand(CommandBase):
    cmd = "jxa_call"
    needs_admin = False
    help_cmd = "jxa_call function_call();"
    description = "Call a function from within the JS file that was imported with 'jxa_import'. This function call is appended to the end of the jxa_import code and called via eval."
    version = 1
    author = "@slyd0g"
    attackmapping = ["T1059.002"]
    argument_class = JXACallArguments

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass