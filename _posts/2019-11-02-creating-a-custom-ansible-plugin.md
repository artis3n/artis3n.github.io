---
layout: post
title: "Galaxy Collections Part 1: Extending Ansible through Custom Plugins"
description: "Extending Ansible through custom collections."
tags: devops development ansible
---

In part 1 of this series we will learn how to develop and use a custom plugin in your Ansible playbook. In [part 2][] we will look at how we can bundle this plugin into an Ansible Collection and automatically package and upload this Collection to Ansible Galaxy.

<!-- markdownlint-disable MD026 -->

- [Why write a custom Ansible plugin?](#why-write-a-custom-ansible-plugin)
- [Choosing a plugin type](#choosing-a-plugin-type)
- [Writing a custom plugin](#writing-a-custom-plugin)
  - [All plugins must be written in Python](#all-plugins-must-be-written-in-python)
  - [All plugins must raise errors](#all-plugins-must-raise-errors)
  - [Return strings in unicode](#return-strings-in-unicode)
  - [Writing the actual behavior](#writing-the-actual-behavior)
  - [Conform to Ansible's configuration and documentation standards](#conform-to-ansibles-configuration-and-documentation-standards)
    - [Viewing the documentation](#viewing-the-documentation)
    - [License](#license)
    - [DOCUMENTATION](#documentation)
    - [EXAMPLES](#examples)
    - [RETURN](#return)
- [Using the custom plugin in your playbook](#using-the-custom-plugin-in-your-playbook)
- [Next Steps](#next-steps)

## Why write a custom Ansible plugin?

Ansible plugins augment Ansible’s core functionality with logic and features that are accessible to all modules. Creating a plugin is actually very simple, however Ansible requires very specific configurations in your plugin code that can make getting the plugin to actually function much more difficult.

The plugin we will create will retrieve the latest tagged release of a GitHub repository. Our version will only work against public GitHub repositories, but you can extend this plugin to run against private repositories by accepting a GitHub token as an environment variable ([relevant GitHub issue][]). The full lookup plugin that we will build can be found [on GitHub][github_version].

Let us suppose that we need to query the GitHub API for the latest tagged release of a repository and use that version number in our tasks. For instance, [here is an example][github_version terraform] where I retrieve the latest release version from GitHub in order to download and verify the checksum for the latest Terraform release from `releases.hashicorp.com`.

We can perform this with the following tasks:

```yaml
- name: Terraform | Get latest release
  uri:
    url: https://api.github.com/repos/hashicorp/terraform/releases/latest
    headers:
      Accept: application/vnd.github.v3+json
    body_format: json
    return_content: yes
  register: terraform_release

- name: Terraform | Set version
  set_fact:
    # This removes the 'v' from the tag: 'v1.1.0' -> '1.1.0'
    ansible_version: "{% raw %}{{ terraform_release.json.tag_name[1:] }}{% endraw %}"
```

Alternatively, if we wanted to do this as a single task we can do it in one command with `shell` (assuming the presence of `jq` already installed on the target host):

```yaml
- name: Terraform | Get the latest version (will include 'v' in the tag name)
  shell: |
    set -o pipefail
    curl -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/hashicorp/terraform/releases/latest | jq .tag_name
  args:
    executable: /bin/bash
  changed_when: false
  register: terraform_version
```

1-2 tasks isn't so great a burden to our playbook but we have to repeat these task(s) every time we want to get a repo's latest release. In my playbook which sets up my local development machine I do this 5 times. Instead of writing 5-10 additional tasks (depending on if you use `uri` and `set_fact` or `shell`), I'd like to simply invoke a plugin inside my other tasks that require this version. With the plugin, we can use a custom lookup:

```yaml
- name: Terraform | Get latest release
  set_fact:
    terraform_version: "{% raw %}{{ lookup('github_version', 'hashicorp/terraform')[1:] }}{% endraw %}"
```

inside any task.

## Choosing a plugin type

The first thing we need to do is decide [what type of Ansible plugin][plugin types] we want to create (spoiler from the code snippet above, we will build a lookup plugin):

- **Action plugins** let you integrate local processing and local data with module functionality
- **Cache plugins** store gathered facts and data retrieved by inventory plugins
- **Callback plugins** add new behaviors to Ansible when responding to events
- **Connection plugins** allow Ansible to connect to the target hosts so it can execute tasks on them
- **Filter plugins** manipulate data
- **Inventory plugins** parse inventory sources and form an in-memory representation of the inventory
- **Lookup plugins** pull in data from external data stores
- **Test plugins** verify data
- **Vars plugins** inject additional variable data into Ansible runs that did not come from an inventory source, playbook, or command line

We want to hit the [GitHub Releases API][] and parse the latest release tag version from the output. This sounds like a [lookup plugin][]. These plugins retrieve data from the file system as well as "external datastores and services."

The Ansible development guide includes [sample implementations][developing plugins] of each plugin type that we can use as a template in our custom plugin. Unfortunately, this template code does not correctly set up the custom plugin. There are additional requirements spread across Ansible's documentation. So let's combine all the requirements and see how to build our plugin.

## Writing a custom plugin

Here's the [sample lookup plugin][] verbatim from Ansible's documentation:

```python
# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = """
      lookup: file
        author: Daniel Hokka Zakrisson <daniel@hozac.com>
        version_added: "0.9"
        short_description: read file contents
        description:
            - This lookup returns the contents from a file on the Ansible controller's file system.
        options:
          _terms:
            description: path(s) of files to read
            required: True
        notes:
          - if read in variable context, the file can be interpreted as YAML if the content is valid to the parser.
          - this lookup does not understand globing --- use the fileglob lookup instead.
"""
from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display

display = Display()


class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):


        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        ret = []
        for term in terms:
            display.debug("File lookup term: %s" % term)

            # Find the file in the expected search path, using a class method
            # that implements the 'expected' search path for Ansible plugins.
            lookupfile = self.find_file_in_search_path(variables, 'files', term)

            # Don't use print or your own logging, the display class
            # takes care of it in a unified way.
            display.vvvv(u"File lookup using %s as file" % lookupfile)
            try:
                if lookupfile:
                    contents, show_data = self._loader._get_file_contents(lookupfile)
                    ret.append(contents.rstrip())
                else:
                    # Always use ansible error classes to throw 'final' exceptions,
                    # so the Ansible engine will know how to deal with them.
                    # The Parser error indicates invalid options passed
                    raise AnsibleParserError()
            except AnsibleParserError:
                raise AnsibleError("could not locate file in lookup: %s" % term)

        return ret
```

Let's break up what is happening here. There are certain requirements all plugins must follow. They must:

- Be written in Python (supporting both Python 2 and 3)
- Raise errors
- Return strings in unicode
- Conform to Ansible's configuration and documentation standards

We will get back to the last point as the sample plugin Ansible provides above does not include all of the necessary configuration and documentation.

### All plugins must be written in Python

Plugins must support whatever Python versions Ansible supports. As of this article's publication, that is Python 2.7 and 3.5+. Their current requirements can be found [here][plugin python compatibility].

To support both Python 2 and 3 in your custom plugin you must set the following headers:

```python
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type
```

In Python 2, a declaration of `__metaclass__ = type` tells Python 2 to create new-style classes (which is the default in Python 3). More information on old-style vs. new-style classes can be found [here][new-style classes].

Plugins must be able to be loaded by Ansible's `PluginLoader`, which means the plugin you create must be a `*Module` class that inherits the Base class type of whatever plugin you want to build. For a lookup plugin, that is `LookupModule` and `LookupBase`. You can get this from the sample module of whatever plugin type you are creating.

```python
from ansible.plugins.lookup import LookupBase

class LookupModule(LookupBase):
```

Additionally, all imports _must_ be in the form of `from <name> import <specific thing>`. Imports are not allowed to use a wildcard: `from __ import *`. You must be explicit and import only the minimum your plugin requires. This is documented [here][import documentation], inside the "developing modules" section of the Ansible documentation. Much of that documentation applies to custom plugins, but not all of it (for example, plugins should not include Python shebang or utf-8 coding comments, as modules must). Simple!

Notice also that the custom plugin's imports are listed _after_ the documentation variables at the top of the file. This breaks linting rule [E402][] which states that all module-level imports should be at the top of the file. Ansible loads the custom module _configuration_ imports at the top of the file (such as the `__futures__` import), but explicitly desires all module-specific imports after the documentation variables. This is to keep the code-dependent imports close to the actual code instead of being separated by documentation strings. As the purpose of linting guidelines is to improve readability, Ansible has made this choice to ignore E402 to improve the readability of their modules.

### All plugins must raise errors

Any errors triggered inside your plugin must raise an `AnsibleError`. `AnsibleError` is the base class of Exception provided by Ansible. Specific error types can be found in [this file][ansible error types]. For example, `AnsibleParserError` can be used for errors reading the input provided to the plugin. This is to allow Ansible to handle errors however it has been configured to in the specific playbook. Since we are creating a lookup plugin, let's use `AnsibleLookupError` for our general raised exceptions.

**Important**: When wrapping errors inside an `AnsibleError`, you must use the `to_native()` function from Ansible. This ensures proper string compatibility between Python versions. This is not mentioned in the sample plugin code :)

Note that `to_native` comes from the protected member `ansible.module_utils.__text`. Normally, you should not use a protected member of another class in your code. However, this is what [Ansible wants us to do][to_native protected member] ¯\\\_(ツ)\_/¯.

```python
from ansible.errors import AnsibleLookupError
from ansible.module_utils._text import to_native

from json import JSONDecodeError, loads

try:
    # Load some response content into JSON
    json_response = loads(response.read().decode("utf-8"))
    version = json_response.get("tag_name")
except JSONDecodeError as e:
    raise AnsibleLookupError("Error parsing JSON from Github API response: %s" % to_native(e))
```

### Return strings in unicode

You must convert any strings returned by your plugin into Python’s unicode type. This ensures that the strings can be processed by Jinja2. To convert a string, use:

```python
from ansible.module_utils._text import to_text
result_string = to_text(result_string)
```

Again, `to_text` comes from the protected member `ansible.module_utils.__text.` Again, this is what [Ansible wants us to do][to_text protected member].

### Writing the actual behavior

We can finally turn to our `run` function and customize the behavior of this plugin. We need to keep the function definition:

```python
def run(self, terms, variables=None, **kwargs):
```

We also must return a list:

```python
versions = []
# ... do things and append items to the list
return versions
```

The lookup plugin must accept a list as input (`terms` can be a list) and output a list. This is in order for the plugin to support `with_*` loops inside an Ansible task.

What we want to do is look up the latest release version for each repo passed into our `terms`. For readability, I renamed `terms` to `repos`. I expect a list in either case, so I can rename the variable however I choose. The convention with Ansible is to leave the variable name `terms`, however.

Let's start by validating our input. First, we need to fail if we don't receive any repo names.

```python
versions = []

if len(repos) == 0:
    raise AnsibleParserError("You must specify at least one repo name")
```

Second, let's validate that each repo we receive are properly formatted according to Github's username and repo name guidelins.

```python
from re import compile as regex_compile

#...
for repo in repos:

    # https://regex101.com/r/CHm7eZ/1
    valid_github_username_and_repo_name = regex_compile(r"[a-z\d\-]+\/[a-z\d\S]+")
    if not repo or not valid_github_username_and_repo_name.match(repo):
        raise AnsibleParserError("repo name is incorrectly formatted: %s" % to_text(repo))
```

The rest of the code will occur within the `for repo in repos` block. When working with network requests in Python I usually use the [requests][python-requests] library. However, this is a 3rd-party library import which is discouraged by Ansible. Instead we want to use the standard library's `urllib`. HOWEVER, `urllib` only supports Python 3+. The Python 2.x version is `urllib2`. So we can only import one but our Ansible module must support both versions. To get around this, Ansible provides us a version-independent `urllib`, `ansible.module_utils.urls`.

As the file states:

> The **urls** utils module offers a replacement for the urllib2 python library.
>
> urllib2 is the python stdlib way to retrieve files from the Internet but it lacks some security features (around verifying SSL certificates) that users should care about in most situations. Using the functions in this module corrects deficiencies in the urllib2 module wherever possible.
>
> There are also third-party libraries (for instance, requests) which can be used to replace urllib2 with a more secure library. However, all third party libraries require that the library be installed on the managed machine. That is an extra step for users making use of a module. If possible, avoid third party libraries by using this code instead.

So, our HTTP request is going to look like:

```python
from ansible.module_utils.urls import open_url

# ...
response = open_url(
    "https://api.github.com/repos/%s/releases/latest" % repo,
    headers={"Accept": "application/vnd.github.v3+json"},
)
```

One bonus to this is that `ansible.module_utils.urls` appears to handle request errors for us, so we don't have to worry about error handling for `HTTPExceptions`. Now we can extract out our JSON release tag, checking to make sure no errors occur:

```python
from json import JSONDecodeError, loads

# ...
try:
    json_response = loads(response.read().decode("utf-8"))

    version = json_response.get("tag_name")
    if version is not None and len(version) != 0:
        versions.append(version)
    else:
        raise AnsibleLookupError(
            "Error extracting version from Github API response:\n%s" % to_text(response.text)
        )
except JSONDecodeError as e:
    raise AnsibleLookupError("Error parsing JSON from Github API response: %s" % to_native(e))
```

The full lookup plugin code is now:

```python
from ansible.errors import AnsibleLookupError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display
from ansible.module_utils._text import to_native, to_text
from ansible.module_utils.urls import open_url

from json import JSONDecodeError, loads
from re import compile as regex_compile

display = Display()

class LookupModule(LookupBase):
    def run(self, repos, variables=None, **kwargs):
        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        versions = []

        if len(repos) == 0:
            raise AnsibleParserError("You must specify at least one repo name")

        for repo in repos:

            # https://regex101.com/r/CHm7eZ/1
            valid_github_username_and_repo_name = regex_compile(r"[a-z\d\-]+\/[a-z\d\S]+")
            if not repo or not valid_github_username_and_repo_name.match(repo):
                # The Parser error indicates invalid options passed
                raise AnsibleParserError("repo name is incorrectly formatted: %s" % to_text(repo))

            display.debug("Github version lookup term: '%s'" % to_text(repo))

            # Retrieve the Github API Releases JSON
            try:
                # ansible.module_utils.urls appears to handle the request errors for us
                response = open_url(
                    "https://api.github.com/repos/%s/releases/latest" % repo,
                    headers={"Accept": "application/vnd.github.v3+json"},
                )
                json_response = loads(response.read().decode("utf-8"))

                version = json_response.get("tag_name")
                if version is not None and len(version) != 0:
                    versions.append(version)
                else:
                    raise AnsibleLookupError(
                        "Error extracting version from Github API response:\n%s" % to_text(response.text)
                    )
            except JSONDecodeError as e:
                raise AnsibleLookupError("Error parsing JSON from Github API response: %s" % to_native(e))

            display.vvvv(u"Github version lookup using %s as repo" % to_text(repo))

        return versions
```

So we have written our custom plugin code and we are done, correct? Actually, we must now properly document this plugin for Ansible tools to successfully process it.

### Conform to Ansible's configuration and documentation standards

We've discussed several of the configuration requirements in the above sections. Let's talk about how Ansible requires your plugin be documented. These documentation strings must be formatted as valid YAML. Ansible will parse these documentation variables to display usage instructions and help. If you are only building a plugin for your personal playbook these are not required. However, they are strongly recommended and _are_ required if you want to submit a pull request to get your plugin accepted into `ansible/ansible`. If you want to upload your plugin to Ansible Galaxy, it is _strongly_ recommended you follow these documentation standards to assist others in using your plugin.

**Important**: The documentation variables must be proper YAML syntax. You can check whether your documentation is formatted correctly by running the `ansible-doc` command described below on your plugin. If documentation is rendered your variables are correctly formatted.

#### Viewing the documentation

You can view any plugin's documentation via `ansible-doc -t <type> <name-of-plugin>`. If you are using a local file plugin not installed to a path in the [ANSIBLE_LOOKUP_PLUGINS][ansible_lookup_plugins variable] variable, you can point `ansible-doc` to your plugin via:

```bash
ANSIBLE_LOOKUP_PLUGINS=<./local/path/to/plugin/directory> ansible-doc -t <type> <name-of-plugin>
```

For example, if you wrote this plugin in a directory in your project named `lookup_plugins/`, you would call:

```bash
ANSIBLE_LOOKUP_PLUGINS=./lookup_plugins ansible-doc -t lookup github_version
```

#### License

This actually should head your document before the documentation variables. This is required for any plugin to be accepted into the Ansible core repo and is strongly recommended for all files uploaded to Ansible Galaxy.

```python
# (c) 2019, Ari Kalfus <dev@quantummadness.com>
# MIT License (see LICENSE)
```

You can use whatever license you desire, however some may not be accepted into Ansible core. Ansible, generally, uses GPL-3.0. In my plugin I have opted for MIT and reference the `LICENSE` file in my plugin's repository. You should also include the year you created the plugin, your name, and an email address (optional but recommended) in your copyright header above the license.

Typically you do not include the full license text in your file, as that can be pretty long. Instead, you list what type of license you invoke (MIT, GPL-3.0, etc.) and reference another file where the full license resides. You can also refernce a URL, as many Ansible files do (<https://www.gnu.org/licenses/gpl-3.0.txt>, in those cases).

#### DOCUMENTATION

Your plugin must have a `DOCUMENTATION` variable. The `DOCUMENTATION` variable is described in-depth [here][documentation variable]. **All fields** are required unless that documentation explicitly says otherwise. Let's look at the documentation for the `github_version` plugin:

```yaml
DOCUMENTATION = r"""
# Include the type of plugin (lookup) and the name that will be invoked in a playbook (github_version)
lookup: github_version
# A list of authors who contributed to this file.
# You can optionally add Github username (suggested) and email (legacy suggested). I opted for both.
author:
  - Ari Kalfus (@artis3n) <dev@quantummadness.com>
# In what version of Ansible this plugin was added.
# If merging a plugin to the ansible/ansible core repo this must be the next non-frozen unreleased version of Ansible.
# Otherwise it doesn't really matter, however I recommend using the next unreleased (not necessarily non-frozen) Ansible version when the module was created.
version_added: "2.9"
# Any Python package requirements for this module. It is STRONGLY recommended that you avoid all 3rd party library packages.
# If you intend to merge into ansible/ansible, your PR will likely be rejected if it uses 3rd party library packages.
# This is to keep the dependency requirements of Ansible small.
requirements:
  - json
  - re
# A few words describing the plugin. This will be displayed from `ansible-doc -l` (list).
short_description: Get the latest tagged release version from a public Github repository.
# A few complete sentences describing the plugin.
description:
  - This lookup returns the latest tagged release version of a public Github repository.
  - A future version will accept an optional Github token to allow lookup of private repositories.
# The parameters or arguments to the plugin.
# Use an empty dictionary ({ }) if the plugin takes no arguments.
# All options used by the plugin should be thoroughly documented.
options:
  # The name of the option
  repos:
    # Description of the option
    description: A list of Github repositories from which to retrieve versions.
    # This means this option must be supplied or the plugin will fail.
    # You must validate the content of the variable yourself in the code.
    required: True
    # You will likely also use the following:
    # default: Mutually exclusive with `required`. Document the default value the plugin will use for this option. You must ensure your function sets this default value.
    # choices: A list of options if only certain specific values are accepted by this option.
    # type: Specify an argspec-compliant type for this option.
    # suboptions: If this option is a dict, you can specify its contents via this attribute.
# Full sentences with any additional information about this module.
notes:
  - The version tag is returned however it is defined by the Github repository.
  - Most repositories used the convention 'vX.X.X' for a tag, while some use 'X.X.X'.
  - Some may use release tagging structures other than semver.
  - This plugin does not perform opinionated formatting of the release tag structure.
  - Users should format the value via filters after calling this plugin, if needed.
# Any additional documentation can be linked via this attribute.
seealso:
  - name: Github Releases API
    description: API documentation for retrieving the latest version of a release.
    link: https://developer.github.com/v3/repos/releases/#get-the-latest-release
"""
```

#### EXAMPLES

Your plugin should have an `EXAMPLES` variable. The `EXAMPLES` variable is described in-depth [here][examples variable]. Include several examples demonstrating how to use your plugin.

```yaml
EXAMPLES = r"""
- name: Get the latest version, also strip the 'v' out of the tag version, e.g. 'v1.0.0' -> '1.0.0'
  set_fact:
    ansible_version: "{% raw %}{{ lookup('github_version', 'ansible/ansible')[1:] }}{% endraw %}"

- name: Operate on multiple repositories
  git:
    repo: https://github.com/{{ item }}.git
    version: "{% raw %}{{ lookup('github_version', item) }}{% endraw %}"
    dest: "{% raw %}{{ lookup('env', 'HOME') }}{% endraw %}/projects"
  with_items:
    - ansible/ansible
    - ansible/molecule
    - ansible/awx
"""
```

#### RETURN

Your plugin should have an `RETURN` variable. The `RETURN` variable is described in-depth [here][return variable]. This section documents what information your plugin returns for use by other modules. As a standard lookup plugin, we return a list.

```yaml
RETURN = r"""
  _list:
    description:
      - List of latest Github repository version(s)
    type: list
"""
```

## Using the custom plugin in your playbook

Now that we've written our plugin, how do we tell Ansible to import it into our playbook? There are certain "[magic directories][]" Ansible will automatically search for to import local modules and plugins. For plugins, Ansible looks for a local directory named for that type of plugin (e.g. `lookup_plugins/`). We can put our `github_version.py` plugin underneath a `lookup_plugins/` directory in our project root and Ansible will automatically import it and make it available inside our playbook context.

Assuming our plugin is located at `lookup_plugins/github_version.py` in our project root, we can now use it:

```yaml
- name: Testing new plugin
  debug:
    msg: "Terraform's latest version: {% raw %}{{ lookup('github_version', 'hashicorp/terraform')[1:] }}{% endraw %}"
```

## Next Steps

Now that we have written our custom plugin, what next? We can package our plugin into an [Ansible Collection][] and upload it to Ansible Galaxy for other users to import into their playbooks. This requires some minor refactors to our plugin setup, which we will discuss in [part 2][] of this series. We will also discuss how to build a [Github Action][] and use one that I created to automatically bundle your collection and upload it to Ansible Galaxy.

[github_version]: ttps://github.com/artis3n/github_version-ansible_plugin/blob/master/plugins/lookup/github_version.py
[developing plugins]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html
[lookup plugin]: https://docs.ansible.com/ansible/latest/plugins/lookup.html
[plugin types]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#developing-particular-plugin-types
[github releases api]: https://developer.github.com/v3/repos/releases/
[github_version terraform]: https://github.com/artis3n/dev-setup/blob/48c2cda1b6f818b9a660871c4521cc9186313de5/tasks/terraform.yml
[sample lookup plugin]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#lookup-plugins
[plugin python compatibility]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-node-requirements
[new-style classes]: https://realpython.com/python-metaclasses/#old-style-vs-new-style-classes
[import documentation]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_documenting.html#python-imports
[E402]: https://lintlyci.github.io/Flake8Rules/rules/E402.html
[ansible error types]: https://github.com/ansible/ansible/blob/devel/lib/ansible/errors/__init__.py
[documentation variable]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_documenting.html#documentation-block
[ansible_lookup_plugins variable]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-lookup-plugin-path
[examples variable]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_documenting.html#examples-block
[return variable]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_documenting.html#return-block
[to_text protected member]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#string-encoding
[to_native protected member]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#raising-errors
[python-requests]: https://pypi.org/project/requests/
[local plugin]: https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html
[ansible collection]: https://docs.ansible.com/ansible/devel/user_guide/collections_using.html
[github action]: https://github.com/features/actions
[part 2]: /2019-11-02-github-action-ansible-galaxy-collection/
[relevant github issue]: https://github.com/artis3n/github_version-ansible_plugin/issues/26
[magic directories]: https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-a-plugin-locally
