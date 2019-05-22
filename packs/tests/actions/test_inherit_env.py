import os

from st2common.runners.base_action import Action


class InheritEnvTestAction(Action):
    def run(self, *args, **kwargs):
        return (True, os.environ)
