from mythic_container.MythicCommandBase import *
import json


class TCCFolderCheckArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class TCCFolderCheckCommand(CommandBase):
    cmd = "tcc_folder_check"
    needs_admin = False
    help_cmd = "tcc_folder_check"
    description = "Uses MDQuery* APIs to determine if you have access to TCC-protected folders (~/Downloads, ~/Desktop/, ~/Documents). Technique inspired by @cedowens who also implemented this check in https://github.com/cedowens/Spotlight-Enum-Kit"
    version = 1
    author = "@slyd0g"
    argument_class = TCCFolderCheckArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass