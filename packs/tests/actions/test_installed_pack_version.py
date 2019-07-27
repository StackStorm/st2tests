# Copyright 2019 Extreme Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from st2common.constants.pack import PACK_VERSION_SEPARATOR
from st2common.runners.base_action import Action
from st2common.util.pack import get_pack_metadata
from st2common.util.pack_management import get_repo_url


class TesetInstalledPackVersionAction(Action):
    def run(self, installed_pack):
        """
        :param installed_pack: Installed pack name with version
        :type: installed_pack: ``string``
        """

        if not installed_pack:
            return False, False

        pack_and_version = installed_pack.split(PACK_VERSION_SEPARATOR)
        pack_name = pack_and_version[0]
        pack_version = pack_and_version[1] if len(pack_and_version) > 1 else None

        # Pack version is not specified. Get pack version from index.json file.
        if not pack_version:
            try:
                _, pack_version = get_repo_url(pack_name, proxy_config=None)
            except Exception:
                print ('No record of the "%s" pack in the index.' % (pack_name))
                return False, False

        # Get installed pack version from local pack metadata file.
        try:
            pack_dir = '/opt/stackstorm/packs/%s/' % (pack_name)
            pack_metadata = get_pack_metadata(pack_dir=pack_dir)
            local_pack_version = pack_metadata.get('version', None)
        except Exception:
            print ('Could not open pack.yaml file at location %s' % (pack_dir))
            return False, False

        if pack_version == local_pack_version:
            return True, True
        else:
            return False, False
