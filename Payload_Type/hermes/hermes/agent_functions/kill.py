from mythic_container.MythicCommandBase import *
import json

class KillArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line) == 0:
            raise Exception("Must supply a PID to kill")
        else:
            try:
                test = int(self.command_line)
            except:
                raise Exception("Must supply an integer parameter")
        pass
    
    async def parse_dictionary(self, dictionary):
        if "process_id" in dictionary:
            # then this came from the process browser
            self.command_line = str(dictionary["process_id"])
        else:
            raise Exception("Unknown dictionary passed in")

class KillCommand(CommandBase):
    cmd = "kill"
    needs_admin = False
    help_cmd = "kill [PID]"
    description = "Kill a process with the specified PID (from ps or list_apps command)"
    version = 1
    supported_ui_features = ["process_browser:kill"]
    author = "@slyd0g"
    argument_class = KillArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass