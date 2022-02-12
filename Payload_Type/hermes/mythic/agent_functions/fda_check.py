from mythic_payloadtype_container.MythicCommandBase import *
import json


class FullDiskAccessCheckArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class FullDiskAccessCheckCommand(CommandBase):
    cmd = "fda_check"
    needs_admin = False
    help_cmd = "fda_check"
    description = "Attempts to access ~/Library/Application\ Support/com.apple.TCC/TCC.db to determine if you have \"Full Disk Access\" permissions. Technique inspired by @cedowens who also implemented this check in https://github.com/cedowens/SwiftBelt-JXA"
    version = 1
    author = "@slyd0g"
    argument_class = FullDiskAccessCheckArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass