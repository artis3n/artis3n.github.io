---
layout: post
title: "Galaxy Collections Part 3: Integration Tests with Molecule"
description: "Using Molecule to test your Ansible Collection content."
tags: devops development ansible
---

In part 3 of this series, we will look at how we can test Ansible Collections using the official Ansible test tool, [Molecule][]. In [part 1][], we created a custom lookup plugin to interact with the GitHub Releases API. In [part 2][], we refactored this plugin into an Ansible Collection and used GitHub Actions to automatically deploy our collection to Ansible Galaxy.

This article will borrow heavily from [Jeff Geerling's article][geerlingguy molecule] on running Molecule tests on an Ansible Collection. I had to make some small changes to his described project layout in order to get Molecule working on my collection, which I will describe here. Additionally, I've created a GitHub Actions workflow to automate Molecule tests as part of CI.

## Directory Structure

If you do not already have a collection you can find one in [part 2][] of my Galaxy Collections series or create one with `ansible-galaxy collection init <namespace>.<name>`. This will set up a collection in the format:

```bash
ansible-galaxy collection install artis3n.github 
```

```text
artis3n/
├── github/
│   ├── docs/
│   ├── plugins/
│   ├── roles/
│   └── README.md
│   └── galaxy.yml
```

You should customize these files as required for your collection (again, you can find a sample setup in [my other article][part 2]).

### Ansible-Required Directory Structure

In order for Molecule (well, Ansible) to find your collection and make it available for your tests your collection _must_ exist at a path in the environment variable `ANSIBLE_COLLECTIONS_PATHS`. We will look at how to easily configure that for Molecule in a moment. However, **Ansible has very strict requirements** on the directory structure for each path in `ANSIBLE_COLLECTIONS_PATHS`. Each path _must_ point to a directory with the following structure:

```text
collections/
├── ansible_collections/
│   ├── artis3n/
│   │   ├── github/
│   ├── .../
```

Ansible will only recognize collections if they exist in `collections/ansible_collections/<namespaces>`. You can pass specific plugins, roles, and modules to Ansible via environment variables such as `ANSIBLE_LOOKUP_PLUGINS`, however that would be very tedious for a whole collection, let alone multiple collections. The simplest thing to do is `ansible-galaxy collection install` collections and let Ansible install them to the default location: `~/.ansible/collections/ansible_collections/`. For testing your own collection locally, you must place it underneath `<some_path>/collections/ansible_collections` and add `<some_path>` to `ANSIBLE_COLLECTIONS_PATHS`.

## Molecule

We won't discuss every item you can/should configure when setting up Molecule as Jeff Geerling does a great job of this in [his article][geerlingguy molecule] mentioned above. Let's focus on the specific items we need to modify to get your local collection visible to your tests.

Set up Molecule for your collection with:

```bash
molecule init scenario
```

This will create a `default` scenario under `molecule/` in your project root. If you already have a `default` scenario for some reason you can install another scenario with:

```bash
molecule init scenario --scenario-name "<some-name>"
```

Customize your Molecule configuration and tests as appropriate for your collection. For the following files, we will assume our present working directory is `<project root>/molecule/default` (or whatever scenario name you have chosen).

### playbook.yml

In your `playbook.yml` file, replace the `roles` part with `collections`:

```yaml

---
- name: Converge
  hosts: all

  collections:
    - artis3n.github
```

You can then add a `tasks` section and add whatever Ansible tasks you want to execute to test your collection items. I suggest making use of Ansible's [assert][ansible assert] module. An example:

```yaml
- name: latest_release | Get the version
  uri:
    url: https://api.github.com/repos/ansible/ansible/releases/latest
    headers:
      Accept: application/vnd.github.v3+json
    body_format: json
    return_content: yes
  register: ansible_release

- name: latest_release | Test the module
  assert:
    that:
      - lookup('artis3n.github.latest_release', 'ansible/ansible') == ansible_release.json.tag_name
```

### molecule.yml

Assuming you have set your collection underneath a `collections/ansible_collections` directory, the setup here is simple. Under the `provisioners` section, add the `ANSIBLE_COLLECTIONS_PATHS` environment variable. Add _both_ your custom location and Ansible's default location, as our GitHub Actions workflow will use the default location to run in CI. Separate each path with a colon `:`.

```yaml
provisioner:
  name: ansible
  lint:
    name: ansible-lint
  env:
    ANSIBLE_COLLECTIONS_PATHS: "~/.ansible/collections:~/Nextcloud/Development/collections"
```

## Running Molecule

Now running `molecule test` will pick up your collection. You should see the following in the `converge` section. The specific tests will be different, of course, depending on what you add to your `playbook.yml`:

```bash
--> Scenario: 'default'
--> Action: 'converge'
[WARNING]: running playbook inside collection artis3n.github

    
    PLAY [Converge] ****************************************************************
    
    TASK [Gathering Facts] *********************************************************
    ok: [instance]
    
    TASK [latest_release | Get the version] ****************************************
    ok: [instance]
    
    TASK [latest_release | Test the module] ****************************************
    ok: [instance] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    
    PLAY RECAP *********************************************************************
    instance                   : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Notably, we see `[WARNING]: running playbook inside collection artis3n.github` means that Molecule has successfully read in our collection.

## Running Molecule from GitHub Actions

We can easily have a GitHub Actions workflow run our tests on every pull request, push, or whatever other CI workflow we desire. Here we see a workflow running on every push:

```yaml
name: Molecule Tests

on: [push]

jobs:
  molecule:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Set up Python 3
      uses: actions/setup-python@v1
      with:
        python-version: '3.x'
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install ansible docker 'molecule[docker]'

    - name: Move project to Ansible-required location
      run: |
        mkdir -p ~/.ansible/collections/ansible_collections/artis3n/github
        cp -r ./ ~/.ansible/collections/ansible_collections/artis3n/github

    - name: Molecule test
      run: |
        molecule test
```

The import points are installing our molecule dependencies:

```bash
pip install ansible docker 'molecule[docker]'
```

And moving our custom collection to Ansible's default collection path:

```bash
mkdir -p ~/.ansible/collections/ansible_collections/artis3n/github
cp -r ./ ~/.ansible/collections/ansible_collections/artis3n/github
```

Then we can run our tests with `molecule test`. We can push a new PR to our GitHub repo and see the action workflow test our code:

![Molecule running in GitHub Actions workflow][molecule workflow]

We can now test our custom collection locally and ensure all changes run through CI.

[molecule]: https://github.com/ansible/molecule
[part 1]: /2019-11-02-creating-a-custom-ansible-plugin/
[part 2]: /2019-11-02-github-action-ansible-galaxy-collection/
[geerlingguy molecule]: https://www.jeffgeerling.com/blog/2019/how-add-integration-tests-ansible-collection-molecule
[ansible assert]: https://docs.ansible.com/ansible/latest/modules/assert_module.html
[molecule workflow]: /assets/img/ansible_galaxy_collection/molecule_workflow.png
