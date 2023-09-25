# Elm-pages Scripts

## Install dependencies

```
npm ci
```

## Launch Vy.no page

```
npm run launch-urls <url> <url> <url>
```

For instance:

```
npm run launch-urls https://digitalekanaler-web.vydev.io/kjop-billetter/togbilletter-og-bussbilletter https://digitalekanaler-web.vydev.io/nn/kjop-billettar/togbillettar-og-bussbillettar https://digitalekanaler-web.vydev.io/en/buy-tickets/train-and-bus-tickets
```

Zsh doesn't like question marks, so remove any `?preview=true` or other query params from the URLs.

## Find module

Run script with:

```
npm run find-module <Module.Name>
```

The script will look for an elm.json,
read it's direct dependencies,
look up each package description
and print the dependency with an exposed module matching
<Module.Name> from the input.
