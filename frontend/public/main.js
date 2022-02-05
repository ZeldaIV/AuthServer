const storage = JSON.parse(localStorage.getItem('storage')) || null;
const timeNow = Date.now();

const flags = {
    storage: storage,
    time_now: timeNow
}

const app = Elm.Main.init({flags: flags})

app.ports.save_.subscribe(storage => {
    localStorage.setItem('storage', JSON.stringify(storage))
    app.ports.load_.send(storage)
})

app.ports.startTime = timeNow;