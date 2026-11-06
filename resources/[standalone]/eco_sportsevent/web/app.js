const container = document.getElementById('passport-container');
const summits = ['josiah', 'chiliad', 'gordo', 'chianski'];

window.addEventListener('message', (event) => {
    const item = event.data;
    if (item.action === 'openPassport') {
        const meta = item.data || {};
        document.getElementById('passport-serial').textContent = meta.serialNumber || 'FS-0000';
        document.getElementById('owner-name').textContent = meta.ownerName || 'Pendaki';
        document.getElementById('summit-progress').textContent = `${meta.grandTotal || 0} / 4 Puncak`;

        summits.forEach((id) => {
            const card = document.getElementById(`card-${id}`);
            const stampText = document.getElementById(`stamp-${id}`);
            const existingSeal = card.querySelector('.seal-badge');
            if (existingSeal) existingSeal.remove();

            const sData = meta.stamps && meta.stamps[id];
            if (sData && sData.completed) {
                card.classList.add('stamped-active');
                stampText.textContent = `SAH: ${sData.timestamp}`;
                stampText.className = 'text-xs font-mono font-bold text-green-800';

                const seal = document.createElement('div');
                seal.className = 'seal-badge';
                seal.textContent = 'SUMMIT VERIFIED';
                card.appendChild(seal);
            } else {
                card.classList.remove('stamped-active');
                stampText.textContent = 'BELUM DISTEMPEL';
                stampText.className = 'text-xs font-mono text-gray-400';
            }
        });

        container.classList.remove('hidden');
    }
});

function closeUI() {
    container.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closePassport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

document.getElementById('btn-close').addEventListener('click', closeUI);
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeUI();
});
