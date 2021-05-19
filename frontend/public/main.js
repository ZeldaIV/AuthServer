const flags = JSON.parse(localStorage.getItem('storage')) || null

const app = Elm.Main.init({ flags: flags })

app.ports.save_.subscribe(storage => {
    localStorage.setItem('storage', JSON.stringify(storage))
    app.ports.load_.send(storage)
})
