from mythic_container.MythicCommandBase import *
import base64


class JxaArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="code",
                type=ParameterType.String,
                description="JXA Code to execute.",
            )
        ]

    async def parse_arguments(self):
        if len(self.command_line) == 0:
            raise Exception("Must provide arguments")
        else:
            try:
                self.load_args_from_json_string(self.command_line)
                self.add_arg(
                    "code", base64.b64encode(self.get_arg("code").encode()).decode()
                )
            except:
                self.add_arg("code", base64.b64encode(self.command_line.encode()).decode())


class JxaCommand(CommandBase):
    cmd = "jxa"
    needs_admin = False
    help_cmd = 'jxa {  "code": "ObjC.import(\'Cocoa\'); $.NSBeep();" }'
    description = "Execute JXA code."
    version = 1
    author = "@slyd0g"
    argument_class = JxaArguments
    attackmapping = ["T1059.002"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass