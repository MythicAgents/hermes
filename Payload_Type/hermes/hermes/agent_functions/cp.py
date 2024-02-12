from mythic_container.MythicCommandBase import *
import json


class CpArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="source",
                type=ParameterType.String,
                description="Source file to copy.",
                parameter_group_info=[
                    ParameterGroupInfo(
                        ui_position=1,
                        required=True
                        )
                    
                ]
            ),
            CommandParameter(
                name="destination",
                type=ParameterType.String,
                description="Source will copy to this location",
                parameter_group_info=[
                    ParameterGroupInfo(
                        ui_position=2,
                        required=True
                        )
                ]
            ),
        ]

    async def parse_arguments(self):
        if len(self.command_line) == 0:
            raise Exception("Must provide arguments")
        else:
            try:
                self.load_args_from_json_string(self.command_line)
            except:
                raise Exception("Failed to load arguments as JSON. Did you use the popup?")


class CpCommand(CommandBase):
    cmd = "cp"
    needs_admin = False
    help_cmd = "cp"
    description = "Copy a file from one location to another."
    version = 1
    author = "@slyd0g"
    argument_class = CpArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        task.display_params = task.args.get_arg("source") + " -> " + task.args.get_arg("destination")
        return task

    async def process_response(self, response: AgentResponse):
        pass