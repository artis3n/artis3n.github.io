---
layout: post
title: "Galaxy Collections Part 2: Automatically Update Your Collection with Github Actions"
description: "Building a Github Action to automatically package and upload a Collection to Ansible Galaxy."
tags: devops development ansible
---

In part 2 of this series we will look at how we can use an Ansible Collection to bundle multiple playbooks, roles, modules, and plugins and import/call each individually as needed in a playbook. We will also learn how to create a GitHub Action to automate the deployment of our collection to Ansible Galaxy.

We will build off of the custom lookup plugin we created in [part 1][] of this series. The final setup for the collection we will build is [on GitHub][].

Often when working with large Ansible playbooks you'll encounter the need to duplicate several tasks with slightly modified parameters, format data similarly across discrete tasks, or import the same roles across multiple separate playbooks. Ansible 2.9, released on October 31, 2019, introduced [Collections][ansible collections] which can be installed via [Ansible Galaxy][].

> Collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plugins.

Previously, Ansible Galaxy was a hub for community-developed roles - a discrete playbook of tasks to reuse of common configuration steps. A role executes all of the tasks inside it. Now, the community can upload a Collection of roles, playbooks, modules, or plugins and invoke each individually in their own playbook, as they like.

- [Collection structure](#collection-structure)
- [The galaxy.yml file](#the-galaxyyml-file)
- [Deploying to Ansible Galaxy (Manual)](#deploying-to-ansible-galaxy-manual)
- [Deploying to Ansible Galaxy (Automated)](#deploying-to-ansible-galaxy-automated)
  - [Building a GitHub Action](#building-a-github-action)
    - [Difference between GitHub Apps and GitHub Actions](#difference-between-github-apps-and-github-actions)
    - [How to construct a JavaScript Action](#how-to-construct-a-javascript-action)
    - [A note about node_modules](#a-note-about-node_modules)
  - [Using a GitHub Action](#using-a-github-action)
- [Wrap-Up](#wrap-up)

## Collection structure

A collection has a specific file setup. None of these directories are required, however you **must** include a `galaxy.yml` file. Ansible only accepts `*.yml` for `galaxy.yml` files. We will discuss what needs to go into this file in a moment. You can fork a collection template repo from [here on GitHub][collection template]. You can also generate a skeleton collection structure through the command `ansible-galaxy collection init`. All `ansible-galaxy collection` commands require Ansible 2.9+.

```text
collection/
├── docs/
├── galaxy.yml
├── plugins/
│   ├── modules/
│   │   └── module1.py
│   ├── inventory/
│   └── .../
├── README.md
├── roles/
│   ├── role1/
│   ├── role2/
│   └── .../
├── playbooks/
│   ├── files/
│   ├── vars/
│   ├── templates/
│   └── tasks/
└── tests/
```

`collection/` encompasses the directory in which we are creating our collection. You can create a directory inside your git repo, but I just let my repo directory be the top-level name so all of the files inside this folder are at the project root. So my directory looks like:

```text
docs/
galaxy.yml
plugins/
├── modules/
│   └── module1.py
├── inventory/
└── .../
README.md
roles/
├── role1/
├── role2/
└── .../
playbooks/
├── files/
├── vars/
├── templates/
└── tasks/
tests/
```

Except, we only need to include the files we are using. We aren't adding any custom roles or playbooks to this collection, just my single custom `github_version` lookup plugin. So my directory structure actually only needs to be:

```text
docs/
galaxy.yml
plugins/
├── lookup/
│   └── github_version.py
README.md
tests/
```

Similarly, I will opt to put all of my documentation in README.md, so I do not need to add anything to the `docs/` directory.

```text
galaxy.yml
plugins/
├── lookup/
│   └── github_version.py
README.md
tests/
```

## The galaxy.yml file

`galaxy.yml` contains all the necessary information Ansible Galaxy needs to process, bundle, and publish a collection. The file's structure is described [here][galaxy.yml metadata] and I recommend you read through that relatively short page to understand how to configure your collection.

Let's look at how we'd configure `galaxy.yml` for our `github_version` plugin collection:

```yaml
---

# The Ansible Galaxy namespace under which this collection will be published.
# This can be a company/brand/organization or product namespace under which all content lives.
# I use my Github username.
namespace: artis3n
# The name of this collection.
name: github_version
# The current version of the collection. Update this each time you want to release a new version to Galaxy.
version: 1.0.2
# The markdown README file for the collection. Galaxy displays this on your collection page.
readme: README.md
# A list of authors who contributed to this collection. Similar to the list inside the custom plugin.
authors:
  - Ari Kalfus (@artis3n) <dev@quantummadness.com>
# Self-explanatory. This should be a short (1-2 sentence) summary.
description: This lookup returns the latest tagged release version of a Github repository.
# Either a single file or a list of license files.
# Note that Ansible Galaxy currently only accepts SPDX licenses - https://spdx.org/licenses/
license_file: LICENSE
# List any collections that this collection requires to be installed for it to be usable.
dependencies: { }
# Add the tags you'd like Ansible Galaxy to associate to your collection.
tags:
  - github
  - repository
  - version
# The URL to your project repository. Galaxy will link to this location.
repository: https://github.com/artis3n/github_version-ansible_plugin
# The URL to your project's documentation. Galaxy will link to this location.
documentation: https://github.com/artis3n/github_version-ansible_plugin
# The URL to your project's issue intake. Galaxy will link to this location.
issues: https://github.com/artis3n/github_version-ansible_plugin/issues
```

I am a visual person, so here is my actual config without the explanatory comments above:

```yaml
---

namespace: artis3n
name: github_version
version: 1.0.2
readme: README.md
authors:
  - Ari Kalfus (@artis3n) <dev@quantummadness.com>
description: This lookup returns the latest tagged release version of a Github repository.
license_file: LICENSE
dependencies: { }
tags:
  - github
  - repository
  - version
repository: https://github.com/artis3n/github_version-ansible_plugin
documentation: https://github.com/artis3n/github_version-ansible_plugin
issues: https://github.com/artis3n/github_version-ansible_plugin/issues
```

## Deploying to Ansible Galaxy (Manual)

Now that we have organized our plugin into a collection we can bundle it and upload to Galaxy. For roles, Galaxy supports auto-importing from a GitHub repository, but does not for collections. Moreover, it seems Galaxy prefers roles to be bundled into a collection, as the direct role import now has a tooltip message saying it is a legacy feature.

![Ansible Galaxy upload options][]

> Import Role from Github: Legacy role import. Does not support Collection format.
> Upload New Collection: Used for distributing Galaxy hosted roles, modules, and plugins.

Instead, we use the `ansible-galaxy` CLI tool to bundle our collection into a .tar.gz archive that we upload to Galaxy. We can upload through the UI as in the screenshot above, but we will use the CLI tool :).

To bundle our collection in preparation for upload, run:

```bash
ansible-galaxy collection build
```

at our collection project root. If you are successful you will see the message:

```text
Created collection for artis3n.github_version at /<redacted>/github_version-ansible_plugin/artis3n-github_version-1.0.2.tar.gz
```

Notice that the version you set in your `galaxy.yml` is included in the name of the archive. You must not change the name of the archive.

Now, to upload our package to Ansible Galaxy run:

```bash
ansible-galaxy collection publish artis3n-github_version-1.0.2.tar.gz --api-key=<api key from Ansible Galaxy>
```

The API key can be found at <https://galaxy.ansible.com/me/preferences>.

![api key][]

At this point your collection is published and available on Ansible Galaxy.

## Deploying to Ansible Galaxy (Automated)

Publishing via the CLI is great and all, but we'd like to automate this. Specifically, upon publishing a new release on my GitHub repo, I'd like to automatically build and upload the new version of my collection to Ansible Galaxy. I wrote a [GitHub Action][] to do just that.

Let's look at how to build your own GitHub Action and then how to use any action to automate workflows in your repository. You can skip straight to [Using a GitHub Action](#using-a-github-action) if you want to see how to automatically upload your collection using my publically available GitHub Action.

Note that you can run a GitHub Action from any trigger on GitHub, like a new merge to master. I opted to trigger the action upon publishing a new release.

GitHub Actions are an automation workflow built directly into the GitHub platform. They are currently in a public beta and set to generally release on November 13, 2019. There is a [whole][github actions workflow] [lot][github actions syntax] [of documentation][github actions building] on how to use GitHub Actions. There are a few core concepts that we should explore in this article, but you'll likely have to refer back to that documentation frequently when creating your first few actions. There is also a [GitHub Learning Lab][] for GitHub Actions, which is decent. I went through the Learning Lab twice but ended up referring to all the documentation to actually understand how to create my action. We will refer back to my action in the next two sections, which is [on GitHub here][action on github].

### Building a GitHub Action

We want to take the `ansible-galaxy` commands from the manual section and run them automatically in our action. You can create a GitHub Action in a [Docker container][github actions docker] or [as JavaScript][github actions javascript].

Docker container actions package your environment with the action code, creating a more consistent and reliable unit of work. Consumers of the action do not have to worry about tools or dependencies. Docker container actions only execute in GitHub-hosted Linux environments.

Javascript actions, on the other hand, can run directly on any of the GitHub-hosted virtual machines (Linux, Windows, and OSX) and separates the action code from the environment used to run the code. JavaScript actions are simpler and execute faster than Docker container actions.

I opted to write a JavaScript action because I did not want to isolate my action code from the environment where it runs. Notably, I need to read in the repository's `galaxy.yml` file to correctly package and upload a collection to Galaxy and I don't want to mess around with dynamic mounting of that data into the Docker container action. Moreover, once GitHub Actions release on November 13, 2019 users will pay per minute of runtime. There is a generous free tier of minutes per month that I don't expect many people will go over, but building an action that runs faster than it would as a container seemed another benefit.

#### Difference between GitHub Apps and GitHub Actions

You might be reading this and be thinking, "GitHub Actions sound very similar to GitHub Apps." They are similar but have particular strengths that make each better suited for different scenarios. Taken directly from [the documentation][github apps v actions]:

> GitHub Apps:
>
> - Run persistently and can react to events quickly
> - Work great when persistent data is needed
> - Work best with API requests that aren't time consuming
> - Run on a server or compute infrastructure that you provide
>
> GitHub Actions:
>
> - Provide automation that can perform continuous integration and continuous deployment
> - Can run directly on a virtual machine or in Docker containers
> - Can include access to a clone of your repository, enabling deployment and publishing tools, code formatters, and command line tools to access your code
> - Don't require you to deploy code or serve an app
> - Have a simple interface to create and use secrets, which enables actions to interact with third-party services without needing to store credentials of the person using the action

If you ask me, GitHub is trying to sell you on Actions over Apps but their points stand. If you are working on CI/CD, throw away your Jenkins server and start writing GitHub Actions!

#### How to construct a JavaScript Action

JavaScript GitHub Actions currently use Node 12.x and should be created in a dedicated repository per action. At the project root, create `action.yml` and `index.js` files. `action.yml` will contain the configuration metadata for this action while `index.js` will be the entrypoint for our action's code.

Your `action.yml` is formatted as follows:

```yaml
---
# The name of your action. This is listed on the GitHub Actions Marketplace.
name: 'Deploy Ansible Galaxy Collection'
# A description of what your action does.
description: 'Builds and deploys a Collection to Ansible Galaxy'
# Your GitHub username and, optionally, email
author: 'Artis3n <dev@quantummadness.com>'
# A map of any input parameters used by your action.
inputs:
  # The name of your input parameter.
  api_key:
    # Describe the input parameter.
    description: |
      Ansible Galaxy API key. This should be stored in a Secret on Github.
      See https://help.github.com/en/github/automating-your-workflow-with-github-actions/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables.
    # Mark whether consumers of your action must supply this parameter.
    required: true
  # A second input parameter.
  galaxy_config_file:
    description: 'A collection must have a galaxy.yml file that contains the necessary information to build a collection artifact. Defaults to "galaxy.yml" in the project root.'
    # Mutually exclusive with 'required.' Set a default value for this parameter if it is not supplied.
    default: 'galaxy.yml'
# For JavaScript actions, identify how this action should be run.
runs:
  # What Node version the action should use. As of publication, the only option is 'node12.'
  using: 'node12'
  # Point to your action's entrypoint file. I have modified it from `index.js` to `dist/index.js`. I will describe why shortly.
  main: 'dist/index.js'
# Some configurations to set for your GitHub Action Marketplace's display.
branding:
  icon: 'box'
  color: 'purple'
```

We'll get to the `dist/index.js` bit in a moment. Let's first create our `index.js` file. We begin, as with any JavaScript, with the imports for our file. Be sure to `npm install` anything you need. Additionally, you should `npm install` some number of GitHub's actions libraries, available in the [actions toolkit][]. These are a set of libraries provided by GitHub to make working with actions easier.

You'll likely always run `npm install @actions/core` for the [core library][]:

> Provides functions for inputs, outputs, results, logging, secrets and variables.

We retrieve our input parameters via this library as well as output any data, if our action does so.

```javascript
const core = require('@actions/core');

const apiKey = core.getInput('api_key', { required: true });
const galaxy_config_file = core.getInput('galaxy_config_file') || 'galaxy.yml';
```

You will also use `core` to fail your job upon errors:

```javascript
const core = require('@actions/core');

try {
  // Stuff
} catch (error) {
  core.setFailed(error.message);
}
```

There are a lot of useful libraries in the actions toolkit, so I recommend you browse that repository. The other action library that we need for our Galaxy upload action is the [actions/exec][] library:

> Provides functions to exec cli tools and process output.

We use this library to trigger our `ansible-galaxy` commands:

```javascript
const exec = require('@actions/exec');

async function buildCollection(namespace, name, version, apiKey) {
    await exec.exec('ansible-galaxy collection build');
    await exec.exec(`ansible-galaxy collection publish ${namespace}-${name}-${version}.tar.gz --api-key=${apiKey}`)
}
```

If you need, you can also [capture exec command output][exec output]. I opted to let the action fail if these commands error:

```javascript
buildCollection(namespace, name, version, apiKey)
    .then(() => { })
    .catch(err => core.setFailed(err.message));
```

We have all the pieces of our action, let's put it together. When this action is triggered, I want to read the repository's `galaxy.yml` file, parse out the collection's namespace, name, and version, and use the consumer's galaxy API key to bundle and publish that version to Ansible Galaxy. With our action libraries, this looks like:

```javascript
const core = require('@actions/core');
const exec = require('@actions/exec');
const yaml = require('js-yaml');
const fs = require('fs');

try {
    const apiKey = core.getInput('api_key', { required: true });
    const galaxy_config_file = core.getInput('galaxy_config_file') || 'galaxy.yml';
    const galaxy_config = yaml.safeLoad(fs.readFileSync(galaxy_config_file, 'utf8'));

    const namespace = galaxy_config.namespace;
    const name = galaxy_config.name;
    const version = galaxy_config.version;

    if (namespace === undefined || name === undefined || version === undefined) {
        const error = new Error("Missing require namespace, name, or version fields in galaxy.yml");
        core.error(error.message);
        core.setFailed(error.message);
    }

    core.debug(`Building collection ${namespace}-${name}-${version}`);
    buildCollection(namespace, name, version, apiKey)
        .then(() => core.debug(`Successfully published ${namespace}-${name} v${version} to Ansible Galaxy.`))
        .catch(err => core.setFailed(err.message));
} catch (error) {
    core.setFailed(error.message);
}

async function buildCollection(namespace, name, version, apiKey) {
    await exec.exec('ansible-galaxy collection build');
    await exec.exec(`ansible-galaxy collection publish ${namespace}-${name}-${version}.tar.gz --api-key=${apiKey}`)
}

```

You can see I've added some additional error checking. Other than that, everything should be explained by the preceding paragraphs.

With this, we can merge our code to master and publish a release. When a repository has an `action.yml` file, GitHub will add new content to the publish release form.

![publish release][]

#### A note about node_modules

**Important**: GitHub downloads each action run in a workflow during runtime and executes it as a complete package of code before you can use workflow commands like `run` to interact with the virtual machine. This means that you must include any package dependencies, such as `@actions/core` or anything else `npm install`ed, in your repository. You have two options:

1. Include `node_modules` in your repository.
2. Use [zeit/ncc][] to bundle your code and point your `action.yml` entrypoint to the bundled file.

I opted for the latter. I added `zeit/ncc` to my `package.json`:

```json
"devDependencies": {
    "@zeit/ncc": "^0.20.5"
  }
```

and added a command to my scripts:

```json
"scripts": {
    "build": "ncc build index.js -o dist"
  },
```

`npm run build` will now package my dependencies and `index.js` file and write a file at `dist/index.js`. In my `action.yml` I have set my GitHub Action to use the bundled file:

```yaml
runs:
  using: 'node12'
  main: 'dist/index.js'
```

### Using a GitHub Action

While action workflows are written in YAML and can be created on a local text editor, I recommend building the workflows on GitHub. GitHub's editor provides auto-complete options and sidebar documentation that I found very helpful to refer to while working on the workflow. To run a GitHub Action workflow in your repository you must create a workflow under `.github/workflows/`. You start the workflow by giving it a name. This is what will appear in the Actions tab of your repository when the workflow is triggered:

```yaml
name: Ansible Galaxy
```

![github actions name][]

Next, let's specify when this workflow should be run. We use the `on` keyword, which takes pretty much every kind of event that happens on GitHub. You can trigger actions based on `push`es, on creation of `pull_request`s, and more. You can also conditionally run the workflow based on certain behaviors of the event, e.g. only when a pull request is created but not when it is edited, merged, or closed.

We want this workflow to run only when new releases are published, which looks like:

```yaml
on:
  release:
    types:
      - published
```

A workflow is made up of one or more jobs, which run in parallel by default. You can run jobs sequentially if needed, but you'd need to review the actions documentation for the details. You can give your jobs any name. I've chosen to name the job `deploy`:

```yaml
jobs:
  deploy:
```

You must specify what type of virtual machine to run the job on. You did this with the `run-on` keyword. The supported operating systems can be found [here][supported OS's]. Each jobs runs with a fresh instance of the virtual environment.

```yaml
runs-on: ubuntu-latest
```

You then list the steps the job will take. GitHub provides several bootstrap steps for common programming languages. Since we need Python, we invoke the `actions/setup-python` action. If your workflow needs to access the contents of your repository you can use the `actions/checkout` action. You invoke another action in your workflow with the `uses` keyword. Otherwise, you can run custom shell commands with the `run` keyword. Here, we use my GitHub Action to deploy to Ansible Galaxy.

```yaml
steps:
    - uses: actions/checkout@v1
    - name: Set up Python 3
      uses: actions/setup-python@v1
      with:
        python-version: 3.6

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install --upgrade ansible
    - name: Report Ansible version
      run: ansible --version

    - name: Deploy the collection
      uses: artis3n/ansible_galaxy_collection@v1
      with:
        api_key: ${% raw %}{{ secrets.GALAXY_API_KEY }}{% endraw %}
```

In the above steps we check out out repository and install Python, Pip, and Ansible. We then invoke our GitHub Action to publish to Galaxy, `artis3n/ansible_galaxy_collection`. This action takes a required input parameter, which we specify with `with`.

You'll notice that I am providing a variable to the `api_key` parameter from something called "secrets." This is a new capability in GitHub with the introduction of Actions. You can [store encrypted secret values][github secrets] in your repo encrypted via [NaCl][]. Our `ansible_galaxy_collection` action requires your Ansible Galaxy API key. Store it in your repo's Secrets and reference it in your workflow via `${% raw %}{{ secrets.<SECRET NAME> }}{% endraw %}`. Secrets are not passed to forks of your repository.

You'll also notice that I am locking my action to a specific major version (`@v1`). The convention with GitHub Actions is to specify a specific major version. Maintainers of actions will publish minor and patch updates to their actions and your workflow will use the latest underneath the same major version. Maintainers are responsible for updating their tags appropriately.

![github secrets settings][]

We can see that a full workflow, while requiring understanding of a lot of documentation and keywords, is pretty short to write:

```yaml
name: Ansible Galaxy

on:
  release:
    types:
      - published

jobs:
  deploy:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1
    - name: Set up Python 3
      uses: actions/setup-python@v1
      with:
        python-version: 3.6

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install --upgrade ansible
    - name: Report Ansible version
      run: ansible --version

    - name: Deploy the collection
      uses: artis3n/ansible_galaxy_collection@v1
      with:
        api_key: ${% raw %}{{ secrets.GALAXY_API_KEY }}{% endraw %}
```

And we are done! If we publish a new release we can see our workflow executes and successfully uploads a new version of our build to Ansible Galaxy.

![actions upload log][]

## Wrap-Up

You can find my action to deploy a collection to Ansible Galaxy [on the GitHub Actions Marketplace][actions marketplace]. The repository for my `github_version` collection is [here][github_version repo]. You can use this collection in your own playbooks by [installing it from Ansible Galaxy][github_version galaxy].

I also welcome your input on an [open issue][github_version name] in my collection. Using a custom collection is pretty verbose (`lookup('artis3n.github_version.github_version)`). Ansible requires this format, so how should I make this less horrible to read? My current thought is to rename my collection to `github` and then call this lookup plugin `release_version` so it would be invoked as `lookup('artis3n.github.release_version')`. What do you think?

[part 1]: /2019-11-02-creating-a-custom-ansible-plugin/
[ansible collections]: https://docs.ansible.com/ansible/devel/user_guide/collections_using.html
[ansible galaxy]: https://galaxy.ansible.com/
[developing collections]: https://docs.ansible.com/ansible/devel/dev_guide/developing_collections.html
[collection template]: https://github.com/bcoca/collection
[on github]: https://github.com/artis3n/github_version-ansible_plugin
[galaxy.yml metadata]: https://docs.ansible.com/ansible/latest/dev_guide/collections_galaxy_meta.html#collections-galaxy-meta
[ansible galaxy upload options]: /img/ansible_galaxy_collection/galaxy_upload_options.png
[api key]: /img/ansible_galaxy_collection/ansible_galaxy_api_key.png
[github action]: https://github.com/features/actions
[github actions workflow]: https://help.github.com/en/github/automating-your-workflow-with-github-actions
[github actions syntax]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions
[github actions building]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/building-actions
[action on github]: https://github.com/artis3n/ansible_galaxy_collection
[github actions name]: /img/ansible_galaxy_collection/github_actions_name.png
[supported OS's]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/virtual-environments-for-github-actions#supported-virtual-environments-and-hardware-resources
[github learning lab]: https://lab.github.com/github/hello-github-actions!
[actions upload log]: /img/ansible_galaxy_collection/ansible_galaxy_action_logs.png
[actions marketplace]: https://github.com/marketplace/actions/deploy-ansible-galaxy-collection
[github_version repo]: https://github.com/artis3n/github_version-ansible_plugin
[github_version galaxy]: https://galaxy.ansible.com/artis3n/github_version
[github_version name]: https://github.com/artis3n/github_version-ansible_plugin/issues/22
[github secrets]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables
[github secrets settings]: /img/ansible_galaxy_collection/github_secrets_settings.png
[nacl]: https://nacl.cr.yp.to/
[github actions docker]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/creating-a-docker-container-action
[github actions javascript]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/creating-a-javascript-action
[github apps v actions]: https://help.github.com/en/github/automating-your-workflow-with-github-actions/about-actions#comparing-github-actions-to-github-apps
[actions toolkit]: https://github.com/actions/toolkit
[core library]: https://github.com/actions/toolkit/tree/master/packages/core
[actions/exec]: https://github.com/actions/toolkit/tree/master/packages/exec
[exec output]: https://github.com/actions/toolkit/tree/master/packages/exec#outputoptions
[publish release]: /img/ansible_galaxy_collection/publish_release.png
[zeit/ncc]: https://github.com/zeit/ncc
