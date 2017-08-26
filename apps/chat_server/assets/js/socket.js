import {Socket} from "phoenix"

let user = document.getElementById("User").innerText
let socket = new Socket("/socket", {params: {user: user}})

socket.connect()

export default socket
