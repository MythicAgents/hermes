from mythic_payloadtype_container.MythicCommandBase import *
import json


class AccessibilityCheckArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class AccessibilityCheckCommand(CommandBase):
    cmd = "accessibility_check"
    needs_admin = False
    help_cmd = "accessibility_check"
    description = "Use AXIsProcessTrusted() to determine if our current context has the 'Accessibility' permission within TCC."
    version = 1
    author = "@slyd0g"
    argument_class = AccessibilityCheckArguments
    attackmapping = ["T1592"]
    
    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass