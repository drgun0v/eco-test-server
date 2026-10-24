// ===========================
//   POS REGISTER SYSTEM V5
//   Themes + Analytics + Receipts + Boss Menu
// ===========================

$(() => {
    let currentCurrency = "$";
    let currentCart = new Map();
    let currentRestaurantId = null;
    let selectedPaymentMethod = "bank";
    let selectedBossMoneyType = "cash"; // New Variable for Boss Menu
    let allRecipes = [];
    let activeCategory = "all";
    
    // NEW: Discount Logic
    let discountApplied = false;

    // Cache employees data for search filtering
    let cachedEmployees = [];

    // Core DOM elements
    const registerContainer = document.getElementById("pos-register-wrapper");
    const bossContainer = document.getElementById("boss-menu-wrapper");
    const menuGrid = document.getElementById("menu-gallery");
    const cartItems = document.getElementById("bill-list");
    const cartSubtotal = document.getElementById("subtotal-value");
    const cartTax = document.getElementById("tax-value");
    const cartTotal = document.getElementById("total-value");
    const cartCountPill = document.getElementById("cart-count-pill");

    const btnCancel = document.getElementById("btn-cancel");
    const btnPay = document.getElementById("btn-pay");
    const searchInput = document.querySelector(".search-bar input");
    const playerDropdown = document.getElementById("player-dropdown");
    const paymentButtons = document.querySelectorAll(".btn-payment:not([data-boss-method])"); // POS buttons

    const imageViewer = document.getElementById("image-viewer");
    const imageEl = document.getElementById("image");
    const kdsContainer = document.getElementById("kds-container");

    // Analytics elements
    const statTotalSalesEl = document.getElementById("stat-total-sales");
    const statTotalOrdersEl = document.getElementById("stat-total-orders");
    const statAvgOrderValueEl = document.getElementById("stat-average-order-value");
    const statBestItemEl = document.getElementById("stat-best-item");

    // Receipts table
    const receiptsTbody = document.getElementById("receipts-tbody");

    // NUI post helper
    function post(event, data = {}) {
        $.post(`https://mt-restaurants/${event}`, JSON.stringify(data));
    }

    // =========================
    //   MESSAGE HANDLER (NUI)
    // =========================
    window.addEventListener("message", (event) => {
        const data = event.data;

        // --- POS REGISTER ---
        if (data.action === "showRegister") {
            currentCurrency = data.currency || "$";
            currentCart.clear();
            allRecipes = data.recipes || [];
            currentRestaurantId = data.restaurantId || null;
            activeCategory = "all";
            
            // Reset discount on open
            discountApplied = false;
            const btnDis = document.getElementById("btn-discount");
            if(btnDis) btnDis.classList.remove("active");

            // Reset service details
            const tableInput = document.getElementById("order-table-num");
            const noteInput = document.getElementById("order-note");
            if(tableInput) tableInput.value = "";
            if(noteInput) noteInput.value = "";

            applyTheme(currentRestaurantId);
            showView("menu");
            buildPlayerDropdown(data.players || []);
            filterAndRebuild();
            requestAnalytics();

            if (bossContainer) bossContainer.style.display = "none";
            if (registerContainer) registerContainer.style.display = "flex";

        // --- BOSS MENU ---
        } else if (data.action === "showBossMenu") {
            currentRestaurantId = data.restaurantId || null;
            applyTheme(currentRestaurantId);
            
            cachedEmployees = data.employees || [];

            if (registerContainer) registerContainer.style.display = "none";
            
            // Update Boss Data (Includes updating the new Society Card Balance)
            const overviewBal = document.getElementById("boss-society-balance");
            if(overviewBal) overviewBal.textContent = data.societyMoney;

            const cardBal = document.getElementById("boss-society-balance-card");
            if(cardBal) cardBal.textContent = data.societyMoney;
            
            // Safety check for employees length to prevent JS error blocking display
            const empCount = data.employees ? data.employees.length : 0;
            const empCountEl = document.getElementById("boss-employee-count");
            if(empCountEl) empCountEl.textContent = empCount;
            
            // Render Lists
            renderEmployees(cachedEmployees);
            renderTopPerformers(cachedEmployees);
            
            if (bossContainer) bossContainer.style.display = "flex";

        // --- OTHER UTILS ---
        } else if (data.action === "show") {
            if (imageViewer && imageEl) {
                $(imageViewer).fadeIn("slow");
                imageEl.src = data.image_url || "";
                post("setUIFocus");
            }
        } else if (data.action === "updateKDS") {
            renderKDS(data.orders || {});
        } else if (data.action === "hide") {
            if (imageViewer) $(imageViewer).fadeOut("slow");
            if (registerContainer) registerContainer.style.display = "none";
            if (bossContainer) bossContainer.style.display = "none";
            post("unsetUIFocus");
        }
    });

    // ESC to close
    document.addEventListener("keyup", (event) => {
        if (event.key === "Escape") {
            if (imageViewer) $(imageViewer).fadeOut("slow");
            if (registerContainer) registerContainer.style.display = "none";
            if (bossContainer) bossContainer.style.display = "none";
            post("unsetUIFocus");
        }
    });

    // =========================
    //   THEME PER RESTAURANT
    // =========================
    function applyTheme(jobId) {
        const root = document.documentElement;
        // Default peach / orange
        let c1 = "#ff8a5b", c2 = "#ff6b3d", c3 = "#ffe8df";

        if (jobId === "bshot") {
            c1 = "#0c4c99"; c2 = "#083366"; c3 = "#cfe0fc";
        } else if (jobId === "lplucker") {
            c1 = "#990c2d"; c2 = "#6b081f"; c3 = "#fccfd7";
        } else if (jobId === "wigwam") {
            c1 = "#ff6b3d"; c2 = "#e05528"; c3 = "#ffe8df";
        }

        root.style.setProperty("--accent", c1);
        root.style.setProperty("--accent-strong", c2);
        root.style.setProperty("--accent-soft", c3);
    }

    // =========================
    //   POS VIEW SWITCHING
    // =========================
    function showView(viewName) {
        document.querySelectorAll(".view").forEach((v) => v.classList.remove("active-view"));
        const target = document.querySelector(`.view-${viewName}`);
        if (target) target.classList.add("active-view");

        document.querySelectorAll(".sidebar-menu .menu-item").forEach((item) => item.classList.remove("active"));
        const activeBtn = document.querySelector(`.menu-item[data-view="${viewName}"]`);
        if (activeBtn) activeBtn.classList.add("active");
    }

    document.querySelectorAll(".menu-item[data-view]").forEach((item) => {
        item.addEventListener("click", () => {
            const view = item.dataset.view;
            showView(view);
            if (view === "analytics") requestAnalytics();
            if (view === "receipts") requestReceipts();
        });
    });

    // =========================
    //   POS LOGIC
    // =========================
    function buildMenuGrid(recipes) {
        if (!menuGrid) return;
        menuGrid.innerHTML = "";
        recipes.forEach((recipe) => {
            if (recipe.active !== 1) return;
            const card = document.createElement("div");
            card.className = "product-card";
            const safeImg = recipe.image_url && recipe.image_url.trim() !== "" ? recipe.image_url : "https://i.ibb.co/S3wBwWH/MENU-IMAGE-NOT-ADDED.png";
            card.innerHTML = `
                <div class="product-card-image-wrapper">
                    <img src="${safeImg}" class="product-card-image" onerror="this.src='https://i.ibb.co/S3wBwWH/MENU-IMAGE-NOT-ADDED.png'">
                </div>
                <div class="product-card-info">
                    <h4 class="product-card-title">${recipe.label}</h4>
                    <div class="product-card-meta"><span>${recipe.description || ""}</span></div>
                </div>
                <div class="product-card-footer">
                    <span class="product-card-price">${currentCurrency}${parseFloat(recipe.price).toFixed(2)}</span>
                    <button class="product-card-button btn-add"><i class="fas fa-plus"></i> Add</button>
                </div>
            `;
            card.dataset.id = recipe.id;
            card.dataset.name = recipe.label;
            card.dataset.price = recipe.price;
            card.dataset.image = recipe.image_url || "";
            menuGrid.appendChild(card);
        });
        document.querySelectorAll(".btn-add").forEach((btn) => {
            btn.addEventListener("click", () => {
                const card = btn.closest(".product-card");
                const id = card.dataset.id;
                if (!currentCart.has(id)) {
                    currentCart.set(id, { name: card.dataset.name, price: parseFloat(card.dataset.price), image: card.dataset.image, qty: 1 });
                } else {
                    currentCart.get(id).qty += 1;
                }
                renderCart();
            });
        });
    }

    function filterAndRebuild() {
        let filtered = [...allRecipes];
        
        // Updated Category Logic for new Buttons
        if (activeCategory !== "all") {
            // Note: Your DB types might be 'drink', 'food', 'dessert'. Ensure these match.
            // If activeCategory is 'drinks', we filter for 'drink' (singular) usually.
            let searchKey = activeCategory;
            if(activeCategory === "drinks") searchKey = "drink"; // Handle plural mismatch if exists
            
            filtered = filtered.filter((r) => (r.type || "").toLowerCase() === searchKey);
        }

        if (searchInput && searchInput.value.trim() !== "") {
            const term = searchInput.value.trim().toLowerCase();
            filtered = filtered.filter((r) => (r.label || "").toLowerCase().includes(term));
        }
        buildMenuGrid(filtered);
    }

    // NEW: Category Icon Click Listener
    document.querySelectorAll(".cat-icon-btn").forEach((btn) => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            // Remove active class from all
            document.querySelectorAll(".cat-icon-btn").forEach((i) => i.classList.remove("active"));
            // Add to clicked
            const target = e.currentTarget; // Ensure we get the button, not the icon inside
            target.classList.add("active");
            
            activeCategory = target.dataset.category || "all";
            if (searchInput) searchInput.value = "";
            filterAndRebuild();
        });
    });

    if (searchInput) searchInput.addEventListener("input", filterAndRebuild);

    function buildPlayerDropdown(players) {
        if (!playerDropdown) return;
        playerDropdown.innerHTML = "";
        if (!players || players.length === 0) {
            const opt = document.createElement("option");
            opt.value = ""; opt.textContent = "No players nearby"; playerDropdown.appendChild(opt); return;
        }
        players.forEach((p) => {
            const opt = document.createElement("option");
            opt.value = p.id; opt.textContent = p.name; playerDropdown.appendChild(opt);
        });
    }

    function renderCart() {
        if (!cartItems) return;
        cartItems.innerHTML = "";
        if (currentCart.size === 0) {
            cartItems.innerHTML = `<li class="bill-empty">Your cart is empty</li>`;
            updateTotals(); updateCartCount(); return;
        }
        currentCart.forEach((item, id) => {
            const li = document.createElement("li");
            li.className = "bill-item";
            li.innerHTML = `
                <img src="${item.image}" class="item-thumb" onerror="this.src='https://i.ibb.co/S3wBwWH/MENU-IMAGE-NOT-ADDED.png'">
                <div class="item-info"><span class="item-name">${item.name}</span><span class="item-price">${currentCurrency}${item.price.toFixed(2)}</span></div>
                <div class="item-qty"><button class="qty-btn" data-id="${id}" data-action="dec">-</button><span>${item.qty}</span><button class="qty-btn" data-id="${id}" data-action="inc">+</button></div>
            `;
            cartItems.appendChild(li);
        });
        updateTotals(); updateCartCount();
    }

    function updateCartCount() {
        if (!cartCountPill) return;
        let totalItems = 0;
        currentCart.forEach((item) => totalItems += item.qty);
        cartCountPill.textContent = totalItems.toString();
    }

    if (cartItems) {
        cartItems.addEventListener("click", (e) => {
            if (!e.target.classList.contains("qty-btn")) return;
            const id = e.target.dataset.id;
            const action = e.target.dataset.action;
            const item = currentCart.get(id);
            if (!item) return;
            if (action === "inc") item.qty += 1;
            else if (action === "dec") { item.qty -= 1; if (item.qty <= 0) currentCart.delete(id); }
            renderCart();
        });
    }

    // NEW: Updated Totals Logic
    function updateTotals() {
        let subtotal = 0;
        currentCart.forEach((item) => subtotal += item.price * item.qty);
        
        // Discount calculation
        let discountAmt = 0;
        if(discountApplied) {
            discountAmt = subtotal * 0.10; // 10%
        }

        const taxable = subtotal - discountAmt;
        const tax = taxable * 0.05;
        const total = taxable + tax;

        if (cartSubtotal) cartSubtotal.textContent = `${currentCurrency}${subtotal.toFixed(2)}`;
        
        // Show/Hide Discount Row
        const discountRow = document.getElementById("discount-row");
        const discountVal = document.getElementById("discount-value");
        if(discountRow && discountVal) {
             if(discountApplied && subtotal > 0) {
                 discountRow.style.display = "flex";
                 discountVal.textContent = `-${currentCurrency}${discountAmt.toFixed(2)}`;
             } else {
                 discountRow.style.display = "none";
             }
        }

        if (cartTax) cartTax.textContent = `${currentCurrency}${tax.toFixed(2)}`;
        if (cartTotal) cartTotal.textContent = `${currentCurrency}${total.toFixed(2)}`;
    }

    // NEW: Cart Action Buttons
    const btnClear = document.getElementById("btn-clear-cart");
    if(btnClear) {
        btnClear.addEventListener("click", () => {
            currentCart.clear();
            discountApplied = false;
            
            // Clear inputs
            const tableInput = document.getElementById("order-table-num");
            const noteInput = document.getElementById("order-note");
            if(tableInput) tableInput.value = "";
            if(noteInput) noteInput.value = "";

            const btnDis = document.getElementById("btn-discount");
            if(btnDis) btnDis.classList.remove("active");
            renderCart();
        });
    }

    const btnDiscount = document.getElementById("btn-discount");
    if(btnDiscount) {
        btnDiscount.addEventListener("click", () => {
            discountApplied = !discountApplied;
            if(discountApplied) btnDiscount.classList.add("active");
            else btnDiscount.classList.remove("active");
            updateTotals();
        });
    }

    paymentButtons.forEach((btn) => {
        btn.addEventListener("click", () => {
            paymentButtons.forEach((b) => b.classList.remove("active"));
            btn.classList.add("active");
            selectedPaymentMethod = btn.dataset.method || "bank";
        });
    });

    if (btnCancel) {
        btnCancel.addEventListener("click", () => {
            if (registerContainer) registerContainer.style.display = "none";
            post("cancel");
            post("unsetUIFocus");
        });
    }

    if (btnPay) {
        btnPay.addEventListener("click", () => {
            if (currentCart.size === 0 || !playerDropdown) return;
            const targetId = parseInt(playerDropdown.value);
            if (!targetId || isNaN(targetId)) return;
            const cartArray = [];
            currentCart.forEach((item, id) => cartArray.push({ id: parseInt(id), amount: item.qty }));
            
            // Capture Service Details
            const tableNum = document.getElementById("order-table-num") ? document.getElementById("order-table-num").value : "";
            const orderNote = document.getElementById("order-note") ? document.getElementById("order-note").value : "";

            post("pay", { 
                restaurantId: currentRestaurantId, 
                targetId, 
                paymentMethod: selectedPaymentMethod, 
                cart: cartArray,
                discount: discountApplied, // Send this status to server
                table: tableNum,
                note: orderNote
            });
            
            if (registerContainer) registerContainer.style.display = "none";
            post("unsetUIFocus");
            currentCart.clear();
            renderCart();
        });
    }

    // =========================
    //   BOSS MENU LOGIC
    // =========================
    
    // 1. Tab Switching Logic - FIX APPLIED HERE
    // Use event delegation or ensure elements exist.
    // The previous code might have been overwritten or not properly attached.
    // We re-attach the listener here.
    const bossNavItems = document.querySelectorAll(".menu-item[data-boss-view]");
    bossNavItems.forEach(btn => {
        btn.addEventListener("click", (e) => {
            // Prevent default behavior just in case
            e.preventDefault();

            // 1. Remove 'active' class from all boss menu items
            bossNavItems.forEach(b => b.classList.remove("active"));
            
            // 2. Add 'active' class to clicked item
            // Use currentTarget to ensure we get the LI element, not the icon inside
            const clickedItem = e.currentTarget;
            clickedItem.classList.add("active");
            
            // 3. Hide all boss views
            document.querySelectorAll(".boss-view").forEach(v => {
                v.style.display = "none";
                v.classList.remove("active-view"); // Remove class just to be safe
            });
            
            // 4. Show the selected view
            const viewName = clickedItem.dataset.bossView;
            const viewId = `view-${viewName}`;
            const targetView = document.getElementById(viewId);
            
            if (targetView) {
                targetView.style.display = "block";
                targetView.classList.add("active-view");
            } else {
                console.error(`Boss View target not found: ${viewId}`);
            }
        });
    });

    // 2. Boss Money Type Toggle (Cash/Bank)
    const bossMoneyBtns = document.querySelectorAll(".btn-payment[data-boss-method]");
    bossMoneyBtns.forEach((btn) => {
        btn.addEventListener("click", () => {
            bossMoneyBtns.forEach((b) => b.classList.remove("active"));
            btn.classList.add("active");
            selectedBossMoneyType = btn.dataset.bossMethod || "cash";
        });
    });

    // 3. Close Button
    const btnCloseBoss = document.getElementById("btn-close-boss");
    if (btnCloseBoss) {
        btnCloseBoss.addEventListener("click", () => {
            if (bossContainer) bossContainer.style.display = "none";
            post("unsetUIFocus");
        });
    }

    // 4. Render Employees
    function renderEmployees(employees) {
        const list = document.getElementById("boss-employees-list");
        if(!list) return;
        list.innerHTML = "";
        
        if (!employees || employees.length === 0) {
            list.innerHTML = "<tr><td colspan='4'>No employees found.</td></tr>";
            return;
        }

        employees.forEach(emp => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>${emp.name}</td>
                <td><span class="badge-grade">${emp.gradeLabel}</span></td>
                <td style="font-weight: bold; color: green;">${emp.sales} sales ($${emp.earnings})</td>
                <td>
                    <button class="btn-secondary" onclick="giveBonus('${emp.identifier}')" style="padding: 4px 8px; font-size: 11px; margin-right: 4px; color: green;"><i class="fas fa-money-bill"></i> Bonus</button>
                    <button class="btn-secondary" onclick="promoteEmployee('${emp.identifier}')" style="padding: 4px 8px; font-size: 11px; margin-right: 4px;">Promote</button>
                    <button class="btn-secondary" onclick="fireEmployee('${emp.identifier}')" style="padding: 4px 8px; font-size: 11px; color: red;">Fire</button>
                </td>
            `;
            list.appendChild(tr);
        });
    }

    // NEW: Search Filter Logic
    $("#boss-employee-search").on("input", function() {
        const val = $(this).val().toLowerCase();
        const filtered = cachedEmployees.filter(e => e.name.toLowerCase().includes(val));
        renderEmployees(filtered);
    });

    // NEW: Render Top 3 Performers
    function renderTopPerformers(employees) {
        const container = document.getElementById("boss-top-performers");
        if (!container) return;
        container.innerHTML = "";
        
        if (!employees || employees.length === 0) {
            container.innerHTML = "<div style='color:#999; font-size:12px;'>No sales data yet.</div>";
            return;
        }

        // Sort by sales descending
        const sorted = [...employees].sort((a, b) => b.sales - a.sales).slice(0, 3);

        if(sorted.length === 0) {
            container.innerHTML = "<div style='color:#999; font-size:12px;'>No sales data yet.</div>";
            return;
        }

        sorted.forEach((emp, index) => {
            const item = document.createElement("div");
            item.className = "performer-item";
            item.innerHTML = `
                <div class="rank-circle">${index + 1}</div>
                <div class="performer-info">
                    <span class="performer-name">${emp.name}</span>
                    <span class="performer-sales">${emp.gradeLabel}</span>
                </div>
                <div class="performer-money">${emp.sales} Sales</div>
            `;
            container.appendChild(item);
        });
    }

    // NEW: Quick Amount Helper
    window.setBossAmount = (amt) => {
        const input = document.getElementById("boss-money-input");
        if(input) input.value = amt;
    };

    // Global Functions for HTML onClick
    window.fireEmployee = (id) => { post("bossAction", { action: "fire", target: id, restaurantId: currentRestaurantId }); };
    window.promoteEmployee = (id) => { post("bossAction", { action: "grade", target: id, restaurantId: currentRestaurantId }); };
    window.giveBonus = (id) => { post("bossAction", { action: "bonus", target: id, restaurantId: currentRestaurantId }); };
    
    // Hire
    const btnHire = document.getElementById("btn-hire-player");
    if(btnHire) {
        btnHire.addEventListener("click", () => {
            post("bossAction", { action: "hire", restaurantId: currentRestaurantId });
        });
    }

    // Deposit / Withdraw with Money Type
    const btnDeposit = document.getElementById("btn-deposit");
    const btnWithdraw = document.getElementById("btn-withdraw");
    const moneyInput = document.getElementById("boss-money-input");

    if(btnDeposit) {
        btnDeposit.addEventListener("click", () => {
            const amount = parseInt(moneyInput.value);
            if(amount > 0) post("bossAction", { 
                action: "deposit", 
                amount: amount, 
                restaurantId: currentRestaurantId,
                moneyType: selectedBossMoneyType // Send 'cash' or 'bank'
            });
        });
    }
    if(btnWithdraw) {
        btnWithdraw.addEventListener("click", () => {
            const amount = parseInt(moneyInput.value);
            if(amount > 0) post("bossAction", { 
                action: "withdraw", 
                amount: amount, 
                restaurantId: currentRestaurantId,
                moneyType: selectedBossMoneyType // Send 'cash' or 'bank'
            });
        });
    }

    // Open Recipe Manager (Switch from Tablet to Context Menu)
    const btnRecipes = document.getElementById("btn-open-recipes");
    if(btnRecipes) {
        btnRecipes.addEventListener("click", () => {
            if (bossContainer) bossContainer.style.display = "none";
            post("openRecipeMenu", { restaurantId: currentRestaurantId });
        });
    }

    // =========================
    //   ANALYTICS & RECEIPTS
    // =========================
    function updateAnalyticsUI(stats) {
        if (!stats) return;
        if (statTotalSalesEl) statTotalSalesEl.textContent = `${currentCurrency}${Number(stats.totalSalesToday || 0).toFixed(2)}`;
        if (statTotalOrdersEl) statTotalOrdersEl.textContent = Number(stats.totalOrdersToday || 0).toString();
        if (statAvgOrderValueEl) statAvgOrderValueEl.textContent = `${currentCurrency}${Number(stats.averageOrderValue || 0).toFixed(2)}`;
        if (statBestItemEl) statBestItemEl.textContent = (stats.bestSellingItemLabel || "—") + (stats.bestSellingItemCount ? ` (${stats.bestSellingItemCount}x)` : "");
    }

    function requestAnalytics() {
        if (!currentRestaurantId) return;
        $.post("https://mt-restaurants/getAnalytics", JSON.stringify({ restaurantId: currentRestaurantId }), (r) => {
            try { updateAnalyticsUI(typeof r === "string" ? JSON.parse(r) : r); } catch(e){}
        });
    }

    function updateReceiptsUI(receipts) {
        if (!receiptsTbody) return;
        receiptsTbody.innerHTML = "";
        if (!receipts || receipts.length === 0) {
            receiptsTbody.innerHTML = '<tr><td colspan="4">No receipts yet.</td></tr>'; return;
        }
        receipts.forEach((r) => {
            const tr = document.createElement("tr");
            tr.innerHTML = `<td>${r.orderId || "-"}</td><td>${r.customer || "-"}</td><td>${currentCurrency}${Number(r.total || 0).toFixed(2)}</td><td>${r.time || "-"}</td>`;
            receiptsTbody.appendChild(tr);
        });
    }

    function requestReceipts() {
        if (!currentRestaurantId) return;
        $.post("https://mt-restaurants/getReceipts", JSON.stringify({ restaurantId: currentRestaurantId }), (r) => {
            try { updateReceiptsUI(typeof r === "string" ? JSON.parse(r) : r); } catch(e){}
        });
    }

    // =========================
    //   KDS
    // =========================
    function renderKDS(orders) {
        if (!kdsContainer) return;
        kdsContainer.innerHTML = "";
        if (!orders) return;
        Object.values(orders).forEach((order) => {
            const ticket = document.createElement("div");
            ticket.className = `kds-ticket ${order.status === "done" ? "done" : ""}`;
            let itemsHTML = "";
            if (order.needs) for (const [label, amount] of Object.entries(order.needs)) itemsHTML += `<li class="kds-item"><span>${amount}x</span> ${label}</li>`;
            ticket.innerHTML = `<div class="kds-header"><span class="kds-title">${order.isDelivery ? "Delivery " : ""}Order #${order.id}</span><span class="kds-timer">${order.status === "done" ? "READY" : "PREP"}</span></div><ul class="kds-items">${itemsHTML}</ul>`;
            kdsContainer.appendChild(ticket);
        });
    }
    
    // =========================
    //   NEW: KEYBOARD SHORTCUTS
    // =========================
    document.addEventListener("keydown", (e) => {
        // Only work if POS is visible
        if (registerContainer.style.display === "none") return;

        // Press 'F' to focus Search (if not already focused)
        if ((e.key === "f" || e.key === "F") && document.activeElement !== searchInput) {
            e.preventDefault();
            searchInput.focus();
        }

        // Press 'Delete' to Clear Cart
        if (e.key === "Delete") {
            const btnClear = document.getElementById("btn-clear-cart");
            if(btnClear) btnClear.click();
        }

        // Press 'Enter' to Pay (if not searching)
        if (e.key === "Enter" && document.activeElement !== searchInput) {
            if(btnPay) btnPay.click();
        }
    });
});