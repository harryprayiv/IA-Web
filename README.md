# IATSE 481 Availability List

### Quick Start
```sh
git clone https://github.com/harryprayiv/IATSE-Web
cd IATSE-Web
git checkout ALPHA
npm install
npm run build
npm run serve
```

### Nix Instructions
```sh
git clone https://github.com/harryprayiv/IATSE-Web
cd IATSE-Web
git checkout ALPHA
direnv allow
dev
```

### Introduction



Compatible with PureScript compiler 15.x

### Initial Setup

**Prerequisites:** This template assumes you already have Git and Node.js installed with `npm` somewhere on your path.

First, clone the repository and step into it:

```sh
git clone git clone https://github.com/harryprayiv/IATSE-Web
cd IATSE-Web
```

Then, install the PureScript compiler, the [Spago](https://github.com/purescript/spago) package manager and build tool, and the [Parcel](https://github.com/parcel-bundler/parcel) bundler. You may either install PureScript tooling _globally_, to reduce duplicated `node_modules` across projects, or _locally_, so that each project uses specific versions of the tools.

To install the toolchain globally:
```sh
npm install -g purescript spago parcel
```

To install the toolchain locally (reads `devDependencies` from `package.json`):
```sh
npm install
```

### Building

You can now build the PureScript source code with:

```sh
# An alias for `spago build`
npm run build
```

### Launching the App

You can launch your app in the browser with:

```sh
# An alias for `parcel dev/index.html --out-dir dev-dist --open`
npm run serve
```

### Development Cycle

If you're using an [editor](https://github.com/purescript/documentation/blob/master/ecosystem/Editor-and-tool-support.md#editors) that supports [`purs ide`](https://github.com/purescript/purescript/tree/master/psc-ide) or are running [`pscid`](https://github.com/kRITZCREEK/pscid), you simply need to keep the previous `npm run serve` command running in a terminal. Any save to a file will trigger an incremental recompilation, rebundle, and web page refresh, so you can immediately see your changes.

If your workflow does not support automatic recompilation, then you will need to manually re-run `npm run build`. Even with automatic recompilation, a manual rebuild is occasionally required, such as when you add, remove, or modify module names, or notice any other unexpected behavior.

### Production

When you are ready to create a minified bundle for deployment, run the following command:
```sh
npm run build-prod
```

Parcel output appears in the `./dist/` directory.

You can test the production output locally with a tool like [`http-server`](https://github.com/http-party/http-server#installation). It seems that `parcel` should also be able to accomplish this, but it unfortunately will only serve development builds locally.
```sh
npm install -g http-server
http-server dist -o
```

If everything looks good, you can then upload the contents of `dist` to your preferred static hosting service.
