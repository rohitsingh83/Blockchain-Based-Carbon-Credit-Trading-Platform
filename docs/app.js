const listings = [
  { code: "MR", project: "Mangrove Restoration", location: "Sundarbans / SIM-2026-001", amount: "420 SCC", price: "0.012 ETH" },
  { code: "WF", project: "Wind Farm North", location: "Rajasthan / SIM-2026-014", amount: "180 SCC", price: "0.009 ETH" },
  { code: "AF", project: "Regenerative Agroforestry", location: "Kerala / SIM-2026-027", amount: "95 SCC", price: "0.015 ETH" }
];
const grid = document.querySelector("#listing-grid");
grid.innerHTML = listings.map((item) => `<article class="listing"><div class="listing-top"><span>LISTING / ACTIVE</span><span>TESTNET</span></div><div class="project-icon">${item.code}</div><h3>${item.project}</h3><div class="location">${item.location}</div><div class="listing-bottom"><div><span>AVAILABLE</span><strong>${item.amount}</strong></div><div><span>PRICE / SCC</span><strong>${item.price}</strong></div><button class="buy">Buy credits ↗</button></div></article>`).join("");
document.querySelectorAll(".buy").forEach((button) => button.addEventListener("click", () => {
  button.textContent = "Demo purchase recorded";
  button.disabled = true;
}));
