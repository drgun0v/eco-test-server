window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "showHud") {
        document.getElementById('bus-hud').classList.remove('hidden');
    } else if (data.action === "hideHud") {
        document.getElementById('bus-hud').classList.add('hidden');
    } else if (data.action === "updateStop") {
        document.getElementById('current-stop-name').innerText = data.stopName;
        document.getElementById('stop-current').innerText = data.current;
        document.getElementById('stop-total').innerText = data.total;

        const percent = Math.floor((data.current / data.total) * 100);
        document.getElementById('progress-percent').innerText = `${percent}%`;
        document.getElementById('progress-fill').style.width = `${percent}%`;

        document.getElementById('action-state').innerText = data.stateText || "Menuju halte berikutnya...";
    }
});