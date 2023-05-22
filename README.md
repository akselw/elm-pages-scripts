# Elm-pages Scripts Test

Run script with:

```
npx elm-pages@beta run FindModule <Module.Name>
```

The script will look for an elm.json,
read it's direct dependencies,
look up each package description
and print the dependency with an exposed module matching
<Module.Name> from the input.
