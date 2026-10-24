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

// Web Audio API untuk efek suara pintu (Chime & Air Brakes)
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

function playDoorChime() {
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'sine';
    // Nada "Ding-Dong" transit
    osc.frequency.setValueAtTime(880, audioCtx.currentTime); // A5
    osc.frequency.setValueAtTime(587.33, audioCtx.currentTime + 0.15); // D5

    gain.gain.setValueAtTime(0.2, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.5);

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.start();
    osc.stop(audioCtx.currentTime + 0.5);
}

function playAirBrakes() {
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    // Suara hisapan rem angin bus (White Noise hiss)
    const bufferSize = audioCtx.sampleRate * 0.4;
    const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
    }

    const noise = audioCtx.createBufferSource();
    noise.buffer = buffer;

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1000;

    const gain = audioCtx.createGain();
    gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.35);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    noise.start();
}

function playAnnouncer(text) {
    if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();

        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = 'en-US';
        utterance.rate = 0.92; // Kecepatan sedikit diperlambat agar terdengar seperti broadcast publik
        utterance.pitch = 1.0;
        utterance.volume = 0.85;

        // Otomatis memilih voice English yang paling natural jika tersedia di browser/OS
        const voices = window.speechSynthesis.getVoices();
        const englishVoice = voices.find(v => v.lang.startsWith('en') && (v.name.includes('Natural') || v.name.includes('Google') || v.name.includes('Microsoft') || v.default));
        if (englishVoice) {
            utterance.voice = englishVoice;
        }

        window.speechSynthesis.speak(utterance);
    }
}

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
    } else if (data.action === "playDoorChime") {
        playDoorChime();
    } else if (data.action === "playAirBrakes") {
        playAirBrakes();
    } else if (data.action === "announceStop") {
        playAnnouncer("Next stop, " + data.stopName);
    }
});