# Git Pull Request Guidelines & Process

## Pull Request Guidelines

### General

* Name feature branches using the pattern **"feature/<JIRA ticket or feature name>"**.
* Pushing direct to master or other non-feature branches is **OK** for typo correction type changes; **no need to do a PR to fix a typo.**
* All reviewers should review a pull request and provide feedback.
* If you cannot review a pull request for whatever reason, note that in the request and remove yourself as a reviewer.
* **All pull requests should have at least two reviewers and more than two is fine**.
* Pull requests should only be merged after all reviewers have approved, so expect to wait for responses from everyone you set as a reviewer.
* **Don't include someone as a reviewer on a pull request just as a means to notify them of changes.**
* Reviewers shouldn't hesitate to add other reviewers if needed.
* Pull request should be run through linters and come back with no errors or warnings. (see section Code Linting below)

### Code Linting

* Bash (.sh):  shellcheck [https://github.com/koalaman/shellcheck](https://github.com/koalaman/shellcheck) (brew install shellcheck)
* Python (.py): pylint [https://github.com/PyCQA/pylint/](https://github.com/PyCQA/pylint/) (pip install pylint)
* Ruby (.rb): rubocop [https://github.com/rubocop-hq/rubocop](https://github.com/rubocop-hq/rubocop)(gem install rubocop)

## Pull Request Process

### Initial setup

If you have the repository you wish to make changes to already checked out. Perform the following to get started:

**Local repo prep**

```
cd <REPOSITORY_NAME>
git checkout master
git pull
```

This will ensure that you are working from a clean starting point and won't have to merge changes that have already been committed to master. You are now ready to start making changes to code.

The naming of your branch is important for a number of reasons. **Many of the automated tests that we run are based on git hooks that look for a few things**. The naming of the branch should follow these standards.

* The **segment before** the "/" should either be **bugfix** or **feature** (Not all pull requests will fit into these two categories, if **you are unsure just use feature**)
* The **segment after** the "/" should be either **OPS** or **CAT** and should align with the ticket you are working against
* The final segment after the ticket is optional but helps the reviewers immediately know what they are looking at and also helps the creator maintain multiple feature branches of the same repository locally without confusion. **This segment should be small and separated by underscores**.


### Example branch creation

```
git checkout -b feature/OPS-5555_some_short_description
```

```
git checkout -b feature/bugfix-6666_some_short_description
```

### Preparing a Pull request

Once you are ready to create a pull request there are a few steps you should take to signal that your code is ready for review.

#### Squash your commits

The purpose of this step is to ensure a clean history in git. It also helps to see all of the work associated with a change in one concise location.


[This document](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History) has a good writeup of how to consolidate your git commits into a single commit.

#### Push your code up to Stash

**Push your branch**

```
git push origin feature/CAT-5555_some_description
```


