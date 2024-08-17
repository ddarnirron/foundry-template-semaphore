# foundry-template-semaphore

A Foundry template for building PSE Semaphore smart contracts.

## Dependencies

- [Rust](https://www.rust-lang.org/tools/install)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [NPM (via NVM)](https://github.com/nvm-sh/nvm)

## Installation

You can install this template to create a new project using the following command:
```shell
forge init -t ddarnirron/foundry-template-semaphore ./custom-semaphore-project
```

Then, install the required test-dependencies:
```shell
cd test/utils && npm install
```

## Getting Started

You can build the project by running:
```shell
forge build
```

And run the tests using:
```shell
forge test --ffi
```

