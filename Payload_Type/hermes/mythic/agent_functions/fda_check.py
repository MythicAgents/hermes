from mythic_payloadtype_container.MythicCommandBase import *
import json


class FullDiskAccessCheckArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="technique",
                type=ParameterType.ChooseOne,
                description="Full Disk Access enumeration technique",
                choices=[
                    "file handle",
                    "mdquery",
                ],
                default_value="mdquery",
                parameter_group_info=[ParameterGroupInfo(
                    required=True
                )]
            ),
        ]

    async def parse_arguments(self):
        if len(self.command_line) == 0:
            raise Exception("Must supply an enumeration technique")
        pass


class FullDiskAccessCheckCommand(CommandBase):
    cmd = "fda_check"
    needs_admin = False
    help_cmd = "fda_check"
    description = "1. Attempts to access ~/Library/Application\ Support/com.apple.TCC/TCC.db to determine if you have \"Full Disk Access\" permissions.\n2. Uses mdquery API calls to determine if you have \"Full Disk Access\" permissions.\nTechnique inspired by @cedowens who also implemented this check in https://github.com/cedowens/SwiftBelt-JXA and https://github.com/cedowens/Spotlight-Enum-Kit"
    version = 1
    author = "@slyd0g"
    argument_class = FullDiskAccessCheckArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass