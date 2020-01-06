## Contributing to APIOAK

You can contribute to the APIOAK project in the following forms.

- Report bugs or usage issues via `Issues` for us to fix.

- Contribute code, documentation or test cases for APIOAK via `Pull Request`.


### How to report a Issues

- Search through [Issues](https://github.com/apioak/apioak/issues) The issue does not exist.

- Open [New Issues](https://github.com/apioak/apioak/issues/new) and briefly describe the issue in the title. Describe 
the detailed version, operating environment, and logs and other information in the content.


### How to contribute code

- Before new features are developed or problems are discovered, they can be announced or reported through the `Issues` 
method.

- If you are contributing code for APIOAK for the first time, you need to click the `Fork` button in the upper right 
corner of the project homepage to put the project` Fork` in your home directory.

- Clone items in home directory to local.
```shell
git clone https://github.com/{username}/apioak.git
```

- Add the backbone warehouse address locally to pull the latest code.
```shell
git remote add upstream https://github.com/apioak/apioak.git
```

- Checkout new branch from upstream repository before each development
```shell
git checkout -b feature/add/contributing/document upstream/master
```

- After feature development is complete, add files to the git change record.
```shell
git add feature/file.lua
```

- Write the commit information. Generally, the commit information will be consistent with the branch name.
```shell
git commit -m "feature: add contributing document."
```

- The changed code is submitted to the same branch as the home directory project.
```shell
git push origin feature/add/contributing/document
```

- After the submission is successful, launch `Pull Request` to the main project on the homepage of the home directory 
project.

- When initiating `Pull Request` to the trunk, if the problem has been announced in the `Issues`, you can fill it 
in the `Pull Request` fill-in,` FIX # ISSUES_ID`, You can associate with Issues, and automatically close Issues 
after Pull Request Merged.
