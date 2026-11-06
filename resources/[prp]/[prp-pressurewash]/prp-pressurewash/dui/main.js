// This script was leaked inside at TCHub and KR Dev X Website so check that out https://tchub.st/dashboard https://www.krdevx.site/

const dist = document.querySelector("#dist");
const ropeTexture = document.querySelector(".ropeTexture");

document.addEventListener("DOMContentLoaded", () => {
    try {
        fetch(`https://prp-pressurewash/prp-pressurewash:duiLoaded`, {method: "POST", body: "{}"});
    } catch(e){}
});

const getComonents = (color) => Array.from({length: 3}, (_, i) => Math.floor(color / 16 ** (2 * i) % 16 ** 2))

// interpolate arrays by component
const interpolate = (arr1, arr2, percent) => arr1.map((v, index) => Math.floor(v + (arr2[index] - v) * (percent / 100)))

function colors(value) {
  const StartColor  = 0x87DA21; // Green
  const MiddleColor = 0xFFD700; // yellow
  const EndColor    = 0xDA2121; // Red
  
  let [start, end, v] = value < 50 
      ? [StartColor, MiddleColor, value * 2 ] 
      : [MiddleColor, EndColor, (value - 50) * 2]

  let interpoled = interpolate(getComonents(start), getComonents(end), v)
  
  return interpoled.reduce((n, component, index) => n + component * (16 ** (index * 2)), 0)
}

function setPercentage(percentage) {
    // change the color of the ropeTexture based on the percentage value with transition between the colors
    ropeTexture.style.backgroundColor = `#${colors(percentage).toString(16).padStart(6, '0')}`;
}

window.addEventListener("message", e => {
    const item = e.data;

    if(item.event === "setPercentage") {
        setPercentage(item.percentage);
    }
})
