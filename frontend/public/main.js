// Initial data passed to Elm (should match `Flags` defined in `Shared.elm`)
// https://guide.elm-lang.org/interop/flags.html
const flags = JSON.parse(localStorage.getItem('model')) || null

// Start our Elm application
const app = Elm.Main.init({ flags: flags })

// Ports go here
// https://guide.elm-lang.org/interop/ports.html

app.ports.outgoing.subscribe(({action, data}) => {
    console.log("Performing action: ", action);
    console.log("with data: ", data);
    if (action === "save") {
        localStorage.setItem('model', JSON.stringify(data));
    }

    if (action === "clear") {
        localStorage.setItem('model', null);
    }
    
});
