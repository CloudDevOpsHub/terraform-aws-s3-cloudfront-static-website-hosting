// Theme toggle
const themeBtn = document.getElementById('themeBtn');
if (localStorage.getItem('theme') === 'light') document.body.classList.add('light');

themeBtn.addEventListener('click', () => {
    document.body.classList.toggle('light');
    localStorage.setItem('theme', document.body.classList.contains('light') ? 'light' : 'dark');
});

// Click counter
const badge = document.getElementById('badge');
const counterBtn = document.getElementById('counterBtn');
let count = parseInt(localStorage.getItem('count') || '0');
badge.textContent = count;

counterBtn.addEventListener('click', () => {
    count++;
    badge.textContent = count;
    localStorage.setItem('count', count);
    if (count % 10 === 0) celebrate();
});

function celebrate() {
    const el = document.createElement('div');
    el.textContent = ['🎉','🚀','⚡'][Math.floor(Math.random() * 3)];
    el.style.cssText = `
        position:fixed; top:50%; left:50%;
        transform:translate(-50%,-50%) scale(0);
        font-size:5rem; pointer-events:none; z-index:9999;
        transition: transform .3s cubic-bezier(.34,1.56,.64,1), opacity .4s;
    `;
    document.body.appendChild(el);
    requestAnimationFrame(() => el.style.transform = 'translate(-50%,-50%) scale(1.2)');
    setTimeout(() => { el.style.opacity = '0'; el.style.transform = 'translate(-50%,-80%) scale(.8)'; }, 600);
    setTimeout(() => el.remove(), 1000);
}

document.addEventListener('keydown', e => {
    if (e.key === ' ' && e.target === document.body) { e.preventDefault(); counterBtn.click(); }
    if (e.key === 't' || e.key === 'T') themeBtn.click();
});
