## 为 APIOAK 贡献

你可以通过以下形式为 `APIOAK` 项目做出贡献。

- 通过 `Issues` 报告错误或使用问题以供我们修复。

- 通过 `Pull Request` 为APIOAK贡献代码、文档或测试用例等。


### 如何通过 Issues 报告问题

- 通过 [Issues](https://github.com/apioak/apioak/issues) 搜索该问题并不存在。

- 打开 [New Issues](https://github.com/apioak/apioak/issues/new) 在标题中简要描述问题。在内容中描述详细的版本、运行环境、及日志
等信息。

Issues 的标题应该以前缀形式标记问题类型，例如： 
> * bug: upstream uir redirect failure. 
> * question: how APIOAK works.  


### 如何通过 Pull Request 贡献代码

- 新功能开发前或发现问题时可以先通过 `Issues` 方式进行公告或报告。

- 如果你是首次为 `APIOAK` 贡献代码，需要在项目主页右上角点击 `Fork` 按钮，把项目 `Fork` 到自己的家目录中。  

- 克隆家目录中的项目到本地。
```shell
git clone https://github.com/{username}/apioak.git
```

- 在本地添加主干仓库地址，用于拉取最新代码。
```shell
git remote add upstream https://github.com/apioak/apioak.git
```

- 每次开发前从上游仓库中 checkout 新分支，注意：每个分支只做一件事，禁止多个功能一次性提交。
```shell
git checkout -b feature/add/contributing/document upstream/master
```

- 功能开发完成后，添加文件到git变更记录。
```shell
git add feature/file.lua
```

- 编写提交信息，一般情况下提交信息会与分支名称保持一致。
```shell
git commit -m "feature: add contributing document."
```

- 变更的代码提交到家目录项目与本地相同的分支中。
```shell
git push origin feature/add/contributing/document
```

- 提交成功后，在自己家目录项目的网页中向主干项目发起 `Pull Request`，即可。

- 在向主干发起 `Pull Request` 时，如果问题已经在 `Issues` 中进行公告，可以在 `Pull Request` 填写内容处填写，`FIX #ISSUES_ID`，
即可关联 `Issues`，在 `Pull Request` Merged 后会自动关闭 `Issues`。
